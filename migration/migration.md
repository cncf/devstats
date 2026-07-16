# THE RUNBOOK — shared `affiliations` DB migration

This edition replaces the earlier pseudo-block notation (`FDW(db)`, `FLIP(db)`, and so on) with executable Bash functions and expands the pilot verification/cutover commands.

The shared mode remains disabled until a project CronJob receives:

```text
GHA2DB_AFFILIATIONS_DB=affiliations
```

The shared lock is `devstats.public.gha_locks`. Lock acquisition is atomic and owner-scoped. There is no automatic stale-lock deletion. Clear an abandoned lock only after confirming that no affiliation import/update job is active:

```sql
delete from gha_locks where name = 'affs_lock';
```

## 1. Load the executable functions

Place `migration-functions.sh` next to this runbook or in the `cncf/devstats` repository root. Run all migration commands from the `cncf/devstats` repository root.

```bash
source ./migration-functions.sh
```

The helper does **not** enable `set -e` in the interactive shell. Each destructive/multi-step function runs fail-fast internally.

Initialize the namespace before every stage and after any possible Patroni switchover:

```bash
preamble devstats-test devel/all_test_dbs.txt
# Later, for production:
# preamble devstats-prod devel/all_prod_dbs.txt
```

This defines:

```text
NS       current namespace
LIST     canonical database-list file
PRIMARY  current Patroni primary pod
```

It also provides:

```text
pgk  <command...>  kubectl exec on the current primary
ki <command...>    kubectl exec -i on the current primary
```

Main migration functions:

```text
create_shared
seed
reconcile [job-name]
maps
fdw <db> [socket|password]
fdw_auth_test <db>
save_fdw_mode socket|password
load_fdw_mode
copy_migration_sql
flip <db>
rollback_db <db>
flip_all_dbs
sanity_db <db>
patch_project_cronjobs <project-key>
wait_project_jobs_drained <project-key>
run_cronjob_once <cronjob-name> [job-name]
show_project_logs <project-key> [interval]
```

`flip_all_dbs` is the executable replacement for the old line:

```bash
echo "=== $db"; # FDW(db); FLIP(db)
```

It loads the FDW mode selected during the pilot, copies/checks the migration SQL on the current primary, validates already-flipped databases, and runs `fdw "$db" ...` followed by `flip "$db"` for every remaining local database.

---

# Immediate current step — test the socket FDW before `FLIP`

You have already run the socket `FDW(db)` block. Do **not** rerun it just to test authentication.

Set the pilot database and run the transactional test:

```bash
preamble devstats-test devel/all_test_dbs.txt
db=sam
fdw_auth_test "$db"
```

The test:

1. Creates a temporary-named foreign table in the project database inside a transaction.
2. Reads it as local roles `postgres`, `gha_admin`, `ro_user`, and `devstats_team`; each read therefore exercises that role's own FDW user mapping.
3. Performs one `gha_admin` insert through FDW.
4. Executes `ROLLBACK`, removing both the test foreign table and the remote inserted row.

A successful run exits with status `0` and prints a `local_role` result for all four roles. `rows_read` can be `0` or `1`; authentication success is what matters. It should also print `INSERT 0 1` and finish with `ROLLBACK`.

On success, persist the decision for this namespace:

```bash
save_fdw_mode socket
```

The selected mode is stored in:

```text
~/.devstats-affs-fdw-mode-devstats-test
```

## Exact standalone SQL for the same test

This is the raw command used by `fdw_auth_test`. It is safe to execute after your already-completed socket FDW setup and before `FLIP`:

```bash
ki psql "$db" -X -v ON_ERROR_STOP=1 <<'SQL'
begin;

create foreign table public.__affs_fdw_auth_test(
  id bigint,
  login varchar(120)
) server affiliations
  options (schema_name 'public', table_name 'gha_actors');

grant select on public.__affs_fdw_auth_test
  to gha_admin, ro_user, devstats_team;
grant insert on public.__affs_fdw_auth_test to gha_admin;

select current_user as local_role,
       (select count(*) from (
          select 1 from public.__affs_fdw_auth_test limit 1
        ) s) as rows_read;

set role gha_admin;
select current_user as local_role,
       (select count(*) from (
          select 1 from public.__affs_fdw_auth_test limit 1
        ) s) as rows_read;
insert into public.__affs_fdw_auth_test(id, login)
values (
  (-9000000000000000000 + pg_backend_pid())::bigint,
  '__fdw_auth_test_' || pg_backend_pid()::text
);
reset role;

set role ro_user;
select current_user as local_role,
       (select count(*) from (
          select 1 from public.__affs_fdw_auth_test limit 1
        ) s) as rows_read;
reset role;

set role devstats_team;
select current_user as local_role,
       (select count(*) from (
          select 1 from public.__affs_fdw_auth_test limit 1
        ) s) as rows_read;
reset role;

rollback;
SQL
```

## Only if the socket test fails

Recreate the server and all four mappings in password mode, then rerun the same test:

```bash
fdw "$db" password
fdw_auth_test "$db"
save_fdw_mode password
```

The password is read from `PG_PASS` inside the PostgreSQL pod. Do not paste it into the terminal or runbook. At the later Helm cutover, password mode additionally requires:

```text
affsFdwUsePassword: '1'
```

Do not continue to `FLIP` until one mode passes `fdw_auth_test` and has been saved.

---

# Shared database preparation functions

## CREATE

For a new namespace only:

```bash
create_shared
```

This creates `affiliations`, loads `affiliations_tables.sql` and `country_codes.sql`, grants read access, and creates the atomic lock table in `devstats`.

## SEED / delta sweep

```bash
seed
```

`seed` copies the canonical database list to the current primary, consolidates all still-local actor tables, preserves every `(id, login)` pair including negative IDs, and upserts all `origin=1` names/emails. Already-flipped databases are skipped because their canonical rows are already in `affiliations`.

## RECONCILE

```bash
reconcile
```

This creates one Job from `devstats-affiliations-import`, waits up to 90 minutes, and prints its complete logs. Any failed Job aborts the step.

## MAPS

```bash
maps
```

---

# Deploy the central import CronJob

Create it as one dedicated release per namespace, after `create_shared`:

```bash
EN=test  # use prod in devstats-prod
helm -n "$NS" get values "devstats-$EN-backups" -o yaml > /tmp/affs-import-values.yaml
```

Edit `/tmp/affs-import-values.yaml`:

```yaml
# Remove backupsProdServer and backupsTestServer.
skipBackups: 1
skipAffiliationsImport: ''
affiliationsDB: affiliations

# devstats-test:
testServer: 1
prodServer: ''

# devstats-prod instead:
# testServer: ''
# prodServer: 1
```

Install:

```bash
helm -n "$NS" install "${NS}-affs-import" ./devstats-helm \
  -f /tmp/affs-import-values.yaml
kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjob devstats-affiliations-import
```

---

# One-project pilot — exact sequence

For the current test pilot:

```bash
preamble devstats-test devel/all_test_dbs.txt
db=sam
PROJECT=sam
SYNC_CJ="devstats-$PROJECT"
AFFS_CJ="devstats-affiliations-$PROJECT"
```

For `sam`, the project key and DB name are identical. For special aggregate projects, keep the distinction explicit: for example project `all` uses DB `allprj`, and project `kubernetes` uses DB `gha`.

## A. Suspend and drain the project's two CronJobs

```bash
kubectl --context "$KUBE_CONTEXT" -n "$NS" patch "cronjob/$SYNC_CJ" \
  --type merge -p '{"spec":{"suspend":true}}'
kubectl --context "$KUBE_CONTEXT" -n "$NS" patch "cronjob/$AFFS_CJ" \
  --type merge -p '{"spec":{"suspend":true}}'
wait_project_jobs_drained "$PROJECT"
```

## B. Final pilot delta and reconciliation

```bash
seed
reconcile "affs-recon-${PROJECT}-$(date +%s)"
seed
maps
```

## C. Configure and test FDW

Because you have already configured socket FDW for `sam`, run:

```bash
fdw_auth_test "$db"
save_fdw_mode socket
```

Password fallback only after a failed socket test:

```bash
fdw "$db" password
fdw_auth_test "$db"
save_fdw_mode password
```

## D. Copy the SQL and flip the project database

```bash
copy_migration_sql
flip "$db"
```

Any migration SQL failure rolls back all table renames and foreign-table creation.

## E. Sanity checks

Recommended single command:

```bash
sanity_db "$db"
```

It performs all of the following checks:

- `gha_actors` is now a foreign table.
- Exactly 11 project foreign tables use server `affiliations`.
- Exactly four user mappings exist.
- Project `count(*) from gha_actors` equals the count in the shared database.
- Every `gha_events.actor_id` resolves in shared `gha_actors`.
- A direct foreign lookup and a local-events/foreign-actors join both produce `EXPLAIN VERBOSE` output containing `Foreign Scan` and `Remote SQL`.

Equivalent exact commands:

```bash
# Relation kind: expected "f".
k psql -X -qAt -v ON_ERROR_STOP=1 "$db" -c \
  "select relkind from pg_class where oid = 'public.gha_actors'::regclass"

# Expected: 11.
k psql -X -qAt -v ON_ERROR_STOP=1 "$db" -c \
  "select count(*) from information_schema.foreign_tables where foreign_table_schema='public' and foreign_server_name='affiliations'"

# Expected: 4.
k psql -X -qAt -v ON_ERROR_STOP=1 "$db" -c \
  "select count(*) from pg_user_mappings where srvname='affiliations'"

# These two counts must match.
k psql -X -qAt -v ON_ERROR_STOP=1 affiliations -c \
  "select count(*) from gha_actors"
k psql -X -qAt -v ON_ERROR_STOP=1 "$db" -c \
  "select count(*) from gha_actors"

# Expected: 0.
k psql -X -v ON_ERROR_STOP=1 -P pager=off "$db" -c "
  select count(*) as missing_actor_ids
  from gha_events e
  where e.actor_id is not null
    and not exists (select 1 from gha_actors a where a.id = e.actor_id);
"

# Pick a real recent actor ID, then prove that a filtered foreign query is shipped remotely.
ACTOR_ID="$(k psql -X -qAt -v ON_ERROR_STOP=1 "$db" -c \
  "select actor_id from gha_events where actor_id is not null order by created_at desc limit 1")"
echo "ACTOR_ID=$ACTOR_ID"
k psql -X -v ON_ERROR_STOP=1 -P pager=off "$db" -c "
  explain (verbose, costs off)
  select id, login from gha_actors where id = $ACTOR_ID;
"

# Prove the real local-table/foreign-table join plans successfully.
k psql -X -v ON_ERROR_STOP=1 -P pager=off "$db" -c "
  explain (verbose, costs off)
  select count(*)
  from gha_events e
  join gha_actors a on a.id = e.actor_id
  where e.created_at > now() - interval '7 days';
"
```

For both `EXPLAIN` commands, inspect the output for a `Foreign Scan` and its `Remote SQL:` line. The direct-ID lookup should show the ID predicate in the remote SQL.

## F. Patch the pilot CronJob environments

Recommended command:

```bash
patch_project_cronjobs "$PROJECT"
```

Equivalent exact commands:

```bash
kubectl --context "$KUBE_CONTEXT" -n "$NS" set env "cronjob/$SYNC_CJ" \
  GHA2DB_AFFILIATIONS_DB=affiliations

kubectl --context "$KUBE_CONTEXT" -n "$NS" set env "cronjob/$AFFS_CJ" \
  GHA2DB_AFFILIATIONS_DB=affiliations \
  GHA2DB_CHECK_IMPORTED_SHA= \
  GET_AFFS_FILES=

kubectl --context "$KUBE_CONTEXT" -n "$NS" set env "cronjob/$SYNC_CJ" --list
kubectl --context "$KUBE_CONTEXT" -n "$NS" set env "cronjob/$AFFS_CJ" --list
```

The two trailing `NAME=` arguments set empty values; they are not shell placeholders.

The project affiliation script forces import off, TSDB update on, and the lock database to `devstats` whenever `GHA2DB_AFFILIATIONS_DB` is set. No temporary `SKIP_IMP_AFFS`, `SKIP_UPD_AFFS`, or `AFFS_LOCK_DB` patch is required.

## G. Run one controlled sync

Keep the affiliation CronJob suspended. Unsuspend only the hourly sync CronJob:

```bash
kubectl --context "$KUBE_CONTEXT" -n "$NS" patch "cronjob/$SYNC_CJ" \
  --type merge -p '{"spec":{"suspend":false}}'
```

Create and follow a manual Job from the patched CronJob:

```bash
SYNC_JOB="pilot-sync-${PROJECT}-$(date +%s)"
run_cronjob_once "$SYNC_CJ" "$SYNC_JOB"
```

After it succeeds:

```bash
show_project_logs "$PROJECT" "2 hours"

k psql -X -v ON_ERROR_STOP=1 -P pager=off "$db" -c \
  "select max(created_at) as newest_event from gha_events"
```

The error-like section printed by `show_project_logs` must be empty or contain only understood non-fatal messages. In particular, there must be no FDW authentication, missing foreign relation, unsupported `ON CONFLICT`, or shared-connection errors.

## H. Run one controlled affiliation TSDB regeneration

The affiliation CronJob may remain suspended; `kubectl create job --from=cronjob/...` still works:

```bash
AFFS_JOB="pilot-affs-${PROJECT}-$(date +%s)"
run_cronjob_once "$AFFS_CJ" "$AFFS_JOB"
```

Inspect its logs again if needed:

```bash
kubectl --context "$KUBE_CONTEXT" -n "$NS" logs "job/$AFFS_JOB" \
  --all-containers=true --tail=-1
```

Verify that the project job did not call `import_affs` and that metric/tag/column work was logged:

```bash
k psql -X -v ON_ERROR_STOP=1 -P pager=off devstats -c "
  select prog, count(*)
  from gha_logs
  where proj = '$PROJECT'
    and dt >= now() - interval '2 hours'
  group by prog
  order by prog;
"

k psql -X -v ON_ERROR_STOP=1 -P pager=off devstats -c "
  select count(*) as project_import_affs_calls
  from gha_logs
  where proj = '$PROJECT'
    and prog = 'import_affs'
    and dt >= now() - interval '2 hours';
"
```

Expected `project_import_affs_calls`: `0`.

After the manual affiliation Job succeeds, unsuspend its schedule:

```bash
kubectl --context "$KUBE_CONTEXT" -n "$NS" patch "cronjob/$AFFS_CJ" \
  --type merge -p '{"spec":{"suspend":false}}'
```

Confirm both CronJobs and their environment:

```bash
kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjob \
  "$SYNC_CJ" "$AFFS_CJ" \
  -o custom-columns='NAME:.metadata.name,SUSPEND:.spec.suspend,SCHEDULE:.spec.schedule,IMAGE:.spec.jobTemplate.spec.template.spec.containers[0].image'

kubectl --context "$KUBE_CONTEXT" -n "$NS" set env "cronjob/$SYNC_CJ" --list
kubectl --context "$KUBE_CONTEXT" -n "$NS" set env "cronjob/$AFFS_CJ" --list
```

## I. Dashboard checks

For `sam` in `devstats-test`:

```bash
BASE="https://${PROJECT}.teststats.cncf.io"
curl -fsS "$BASE/api/health" | jq .

printf '%s\n' \
  "$BASE/d/4/companies-stats?orgId=1" \
  "$BASE/d/5/companies-summary?orgId=1" \
  "$BASE/d/7/contributing-companies?orgId=1" \
  "$BASE/d/50/countries-stats?orgId=1"
```

Open the printed URLs and verify:

- dashboards load without SQL errors;
- company and country selectors are populated;
- panels have plausible historical data;
- no panel reports a missing `gha_actors*`, `gha_companies`, `gha_countries`, `gha_bot_logins`, or `gha_map_*` relation;
- panel latency is not materially worse than the pre-flip baseline.

## J. Pilot rollback

Keep the three SQL files on the current primary. Suspend the two pilot CronJobs, drain them, then:

```bash
rollback_db "$db"
```

Remove the temporary environment patches or restore the owning Helm release values before resuming the CronJobs.

---

# Full namespace `SWITCHOVER`

Run this only after the pilot soak passes.

## 1. Reinitialize the namespace and load its saved FDW mode

```bash
preamble devstats-test devel/all_test_dbs.txt
# Production later:
# preamble devstats-prod devel/all_prod_dbs.txt
load_fdw_mode
```

For production, run and save the production pilot decision separately; the file will be:

```text
~/.devstats-affs-fdw-mode-devstats-prod
```

## 2. Suspend all non-backup CronJobs and drain active Jobs

```bash
kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjobs -o name \
  | grep -v backup \
  | xargs -n1 -I{} kubectl --context "$KUBE_CONTEXT" -n "$NS" patch {} \
      --type merge -p '{"spec":{"suspend":true}}'

while true; do
  active="$(kubectl --context "$KUBE_CONTEXT" -n "$NS" get jobs \
    -o jsonpath='{range .items[?(@.status.active>0)]}{.metadata.name}{"\n"}{end}')"
  [[ -z "$active" ]] && break
  echo "waiting for active jobs:"
  printf '%s\n' "$active"
  sleep 30
done
```

## 3. Final delta, reconciliation, and enrichment re-sweep

```bash
seed
reconcile "affs-cutover-$(date +%s)"
seed
maps
```

## 4. Resolve the current primary again and flip every project DB

```bash
preamble "$NS" "$LIST"
flip_all_dbs
```

`flip_all_dbs` does the following for each canonical DB:

- `relkind='f'`: validate 11 foreign tables and four mappings, then skip;
- `relkind='r'`: configure FDW using the saved socket/password choice, copy/verify migration SQL, and flip transactionally;
- any other state: abort the namespace cutover.

## 5. Upgrade every project-CronJob-owning Helm release

Discover and upgrade the owning releases with one executable block:

```bash
load_fdw_mode

RELEASES="$(
  kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjobs -o json \
    | jq -r '.items[]
        | select((.metadata.labels.type == "cron") or (.metadata.labels.type == "affiliations-cron"))
        | .metadata.annotations["meta.helm.sh/release-name"] // "<no-owner>"' \
    | sort -u
)"

if printf '%s\n' "$RELEASES" | grep -qx '<no-owner>'; then
  echo "ABORT: at least one project CronJob has no Helm release owner" >&2
  exit 1
fi

FDW_HELM_ARGS=()
if [[ "$AFFS_FDW_MODE" == "password" ]]; then
  FDW_HELM_ARGS+=(--set-string affsFdwUsePassword=1)
fi

for rel in $RELEASES; do
  echo "=== helm upgrade $rel"
  helm -n "$NS" get values "$rel" -o yaml > "/tmp/vals-$rel.yaml"
  helm -n "$NS" upgrade "$rel" ./devstats-helm \
    -f "/tmp/vals-$rel.yaml" \
    --set-string affiliationsDB=affiliations \
    --set-string checkImportedSHA= \
    --set-string affiliationsGetAffsFiles= \
    --set-string skipAffiliationsImport=1 \
    "${FDW_HELM_ARGS[@]}"
done
```

Do not use `--reuse-values` as the only preservation mechanism.

## 6. Unsuspend all CronJobs

```bash
kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjobs -o name \
  | xargs -n1 -I{} kubectl --context "$KUBE_CONTEXT" -n "$NS" patch {} \
      --type merge -p '{"spec":{"suspend":false}}'
```

Explicitly verify the central importer:

```bash
kubectl --context "$KUBE_CONTEXT" -n "$NS" patch \
  cronjob/devstats-affiliations-import \
  --type merge -p '{"spec":{"suspend":false}}'
```

---

# Stages

## Stage 0 — code out the door

1. Review and commit all four repositories. Build and push images. Render-check the Helm chart.
2. No blanket Helm upgrade is required for the existing sliced releases. Existing CronJobs pick up the newly pushed images through their configured pull policy. Shared behavior remains disabled until `GHA2DB_AFFILIATIONS_DB` is explicitly set.

## Stage 1 — `devstats-test`

```bash
source ./migration-functions.sh
preamble devstats-test devel/all_test_dbs.txt
create_shared
seed
```

Deploy the test central importer release, then:

```bash
reconcile
```

Run the one-project pilot exactly as documented above. After a successful soak, execute the full namespace `SWITCHOVER` section for `devstats-test`.

## Stage 2 — `devstats-prod`

```bash
preamble devstats-prod devel/all_prod_dbs.txt
create_shared
seed
```

Deploy the production central importer release, then:

```bash
reconcile
```

Pilot `tuf` using:

```bash
db=tuf
PROJECT=tuf
```

After the production pilot soak, execute full namespace `SWITCHOVER` with:

```bash
preamble devstats-prod devel/all_prod_dbs.txt
```

## Stage 3 — soak and cleanup

For several days monitor project errors, FDW connections, daily central imports, backups, dashboard correctness, and sync durations.

Spot check actor coverage:

```bash
k psql -X -v ON_ERROR_STOP=1 -P pager=off "$db" -c "
  select count(*)
  from gha_events e
  where e.actor_id is not null
    and not exists (select 1 from gha_actors a where a.id = e.actor_id);
"
```

Expected: `0`.

After rollback retention and restore checks are complete, remove the old local copies:

```bash
for db in $(cat "$LIST"); do
  k psql -X -v ON_ERROR_STOP=1 "$db" -c "
    drop table if exists
      gha_actors_pre_fdw,
      gha_actors_emails_pre_fdw,
      gha_actors_names_pre_fdw,
      gha_companies_pre_fdw,
      gha_actors_affiliations_pre_fdw,
      gha_countries_pre_fdw,
      gha_imported_shas_pre_fdw,
      gha_bot_logins_pre_fdw;
  "
done
```
