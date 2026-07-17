1) First create shared objects on `devstats-test`:
```
export KUBE_CONTEXT=test
source ./migration-functions.sh
preamble devstats-test devel/all_test_dbs.txt
create_shared
seed
```
- Now we need IMPORT-CJ — deploy the central daily import cronjob as a new dedicated release:
```
EN=test
helm -n "$NS" get values devstats-$EN-backups -o yaml > /tmp/affs-import-values.yaml
# edit /tmp/affs-import-values.yaml:
#   remove: backupsProdServer, backupsTestServer
#   add:    skipBackups: 1
#           skipAffiliationsImport: ''
#           affiliationsDB: affiliations
#           prodServer: ''
#           testServer: 1
helm -n "$NS" install "${NS}-affs-import" ./devstats-helm -f /tmp/affs-import-values.yaml
kubectl $KUBE_CONTEXT -n "$NS" get cronjob devstats-affiliations-import
```
- Now run `reconcile`. This finishes the shared part.

2) Pilot on smallest DB - sam, openwhisk (on devstats-test):
- Get smallest candidates: `pgk psql -tAc "select datname from pg_database where datname = any(string_to_array('$(cat devel/all_test_dbs.txt)',' ')) order by pg_database_size(datname) limit 3"`.
```
PROJECT=openwhisk
db=openwhisk
SYNC_CJ="devstats-$PROJECT"
AFFS_CJ="devstats-affiliations-$PROJECT"
kubectl --context "$KUBE_CONTEXT" -n "$NS" patch "cronjob/$SYNC_CJ" --type merge -p '{"spec":{"suspend":true}}'
kubectl --context "$KUBE_CONTEXT" -n "$NS" patch "cronjob/$AFFS_CJ" --type merge -p '{"spec":{"suspend":true}}'
wait_project_jobs_drained "$PROJECT"
seed
reconcile
seed
maps
fdw $db "$AFFS_FDW_MODE"
fdw_auth_test $db
save_fdw_mode $AFFS_FDW_MODE
load_fdw_mode
copy_migration_sql
flip "$db"
sanity_db $db
patch_project_cronjobs $PROJECT
# rollback_db $db
```
- Now do some 1st time passes/tests:
```
PILOT_START="$(pgk psql -X -qAt -v ON_ERROR_STOP=1 devstats -c 'select clock_timestamp()::timestamp')"
echo "$PILOT_START"
SYNC_JOB="pilot-sync-${PROJECT}-$(date +%s)"
run_cronjob_once "$SYNC_CJ" "$SYNC_JOB"
sanity_db "$db"
show_project_logs "$PROJECT" "2 hours"
pgk psql -X -v ON_ERROR_STOP=1 -P pager=off "$db" -c "select max(created_at) as newest_event from gha_events"
AFFS_JOB="pilot-affs-${PROJECT}-$(date +%s)"
run_cronjob_once "$AFFS_CJ" "$AFFS_JOB"
pgk psql -X -v ON_ERROR_STOP=1 -P pager=off devstats -c "select name, owner, dt from gha_locks where name = 'affs_lock'"
```
- Unsuspend normal CJs:
```
kubectl --context "$KUBE_CONTEXT" -n "$NS" patch "cronjob/$SYNC_CJ" --type merge -p '{"spec":{"suspend":false}}'
kubectl --context "$KUBE_CONTEXT" -n "$NS" patch "cronjob/$AFFS_CJ" --type merge -p '{"spec":{"suspend":false}}'
kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjob "$SYNC_CJ" "$AFFS_CJ" -o custom-columns='NAME:.metadata.name,SUSPEND:.spec.suspend,SCHEDULE:.spec.schedule'
```
- Check after one day:
```
sanity_db $db
show_project_logs $db "24 hours"
```

3) Full switchover for all remaining `devstats-test` projects.

- Start this only after the `sam` and `openwhisk` pilots have completed their soak and their scheduled syncs are healthy.
- Run everything from the `cncf/devstats` repository root.
- The Helm chart is assumed to be in the sibling `cncf/devstats-helm` repository.

### 3.1 Initialize and load the tested FDW mode

```
export KUBE_CONTEXT=test
source ./migration-functions.sh
preamble devstats-test devel/all_test_dbs.txt
load_fdw_mode

echo "NS=$NS"
echo "PRIMARY=$PRIMARY"
echo "AFFS_FDW_MODE=$AFFS_FDW_MODE"

CHART="${CHART:-../devstats-helm/devstats-helm}"
test -d "$CHART" || {
  echo "ABORT: Helm chart directory not found: $CHART"
  false
}
```

Expected FDW mode after the completed test pilot:

```
socket
```

### 3.2 Save existing CronJob suspend states, then suspend every CronJob

Saving the old states prevents unintentionally enabling a CronJob that was already intentionally suspended before the migration.

```
SUSPEND_STATE="/tmp/${NS}-cronjob-suspend-state.tsv"

kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjobs -o json |
jq -r '
  .items[]
  | [
      .metadata.name,
      ((.spec.suspend // false) | tostring)
    ]
  | @tsv
' > "$SUSPEND_STATE"

cat "$SUSPEND_STATE"

while IFS="$(printf '\t')" read -r cj was_suspended
do
  test -n "$cj" || continue
  echo "Suspending $cj"
  kubectl --context "$KUBE_CONTEXT" -n "$NS" patch \
    "cronjob/$cj" \
    --type merge \
    -p '{"spec":{"suspend":true}}' || exit 1
done < "$SUSPEND_STATE"
```

This includes:

- all hourly project sync CronJobs;
- all project affiliation CronJobs;
- `devstats-affiliations-import`;
- backups and maintenance CronJobs.

### 3.3 Wait until all active Jobs have drained

```
while true
do
  active="$(
    kubectl --context "$KUBE_CONTEXT" -n "$NS" get jobs -o json |
    jq '[.items[] | select((.status.active // 0) > 0)] | length'
  )"

  if test "$active" -eq 0
  then
    echo "All active Jobs drained"
    break
  fi

  echo "Waiting for $active active Job(s):"
  kubectl --context "$KUBE_CONTEXT" -n "$NS" get jobs -o json |
  jq -r '
    .items[]
    | select((.status.active // 0) > 0)
    | [
        .metadata.name,
        (.status.startTime // "-"),
        ((.status.active // 0) | tostring)
      ]
    | @tsv
  '

  sleep 30
done
```

Do not proceed while an hourly sync, project affiliations regeneration, or central import Job is active.

### 3.4 Perform the final shared-data sweep and reconciliation

All normal writers are now stopped.

```
seed
reconcile "affs-recon-full-${NS}-$(date +%s)"
seed
maps
```

The order is intentional:

1. First `seed` captures the final local actor and `origin=1` enrichment state.
2. `reconcile` imports and correlates the shared affiliation data.
3. Second `seed` captures any final `origin=1` name/email changes made during reconciliation marking.
4. `maps` rebuilds the canonical shared lookup maps after that final sweep.

Verify that the shared lock was released:

```
pgk psql -X -v ON_ERROR_STOP=1 -P pager=off devstats -c "
  select name, owner, dt
  from gha_locks
  where name = 'affs_lock';
"
```

Expected: zero rows.

### 3.5 Re-resolve Patroni primary and flip every remaining database

The long reconciliation may span a Patroni failover, so refresh the primary before database changes.

```
preamble devstats-test devel/all_test_dbs.txt
load_fdw_mode

echo "Current primary: $PRIMARY"
echo "Using FDW mode: $AFFS_FDW_MODE"

flip_all_dbs
```

`flip_all_dbs`:

- skips and validates `sam` and `openwhisk`, which are already migrated;
- creates and tests FDW plumbing for every remaining local project database;
- performs each database flip in one transaction;
- fails closed on missing, partial, or unexpected relation states.

Do not continue to the Helm updates if this function returns an error.

### 3.6 Persist shared mode in every project CronJob Helm release

First identify every release that owns an hourly or project-affiliations CronJob.

```
NO_OWNER="$(
  kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjobs -o json |
  jq '
    [
      .items[]
      | select(
          ((.metadata.labels.type // "") == "cron")
          or
          ((.metadata.labels.type // "") == "affiliations-cron")
        )
      | select(
          (.metadata.annotations["meta.helm.sh/release-name"] // "") == ""
        )
    ]
    | length
  '
)"

if test "$NO_OWNER" -ne 0
then
  echo "ABORT: $NO_OWNER project CronJob(s) have no Helm release owner"
  kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjobs -o json |
  jq -r '
    .items[]
    | select(
        ((.metadata.labels.type // "") == "cron")
        or
        ((.metadata.labels.type // "") == "affiliations-cron")
      )
    | select(
        (.metadata.annotations["meta.helm.sh/release-name"] // "") == ""
      )
    | .metadata.name
  '
  false
fi

REGULAR_RELEASES="$(
  kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjobs -o json |
  jq -r '
    .items[]
    | select(.metadata.name != "devstats-affiliations-import")
    | select(
        ((.metadata.labels.type // "") == "cron")
        or
        ((.metadata.labels.type // "") == "affiliations-cron")
      )
    | .metadata.annotations["meta.helm.sh/release-name"]
    | select(. != null and . != "")
  ' |
  sort -u
)"

echo "$REGULAR_RELEASES"
test -n "$REGULAR_RELEASES" || {
  echo "ABORT: no project CronJob Helm releases found"
  false
}
```

Create the shared-mode override file for ordinary project releases:

```
AFFS_FDW_USE_PASSWORD=""
if test "$AFFS_FDW_MODE" = "password"
then
  AFFS_FDW_USE_PASSWORD="1"
fi

OVERRIDES="/tmp/affiliations-cutover-${NS}.yaml"

cat > "$OVERRIDES" <<EOF
affiliationsDB: "affiliations"
checkImportedSHA: ""
affiliationsGetAffsFiles: ""
skipAffiliationsImport: "1"
affsFdwUsePassword: "$AFFS_FDW_USE_PASSWORD"
EOF

cat "$OVERRIDES"
```

Upgrade each ordinary release while preserving its existing release-specific values:

```
for rel in $REGULAR_RELEASES
do
  VALUES_FILE="/tmp/values-${NS}-${rel}.yaml"

  echo "=== Saving values for $rel"
  helm --kube-context "$KUBE_CONTEXT" -n "$NS" \
    get values "$rel" -o yaml > "$VALUES_FILE" || exit 1

  echo "=== Upgrading $rel"
  helm --kube-context "$KUBE_CONTEXT" -n "$NS" \
    upgrade "$rel" "$CHART" \
    -f "$VALUES_FILE" \
    -f "$OVERRIDES" || exit 1
done
```

Do not upgrade the dedicated `${NS}-affs-import` release with `skipAffiliationsImport: "1"`. That release must remain the single owner of `devstats-affiliations-import`.

### 3.7 Verify effective CronJob environments

Hourly project CronJobs:

```
kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjobs \
  -l type=cron -o json |
jq -r '
  .items[]
  | . as $cj
  | ($cj.spec.jobTemplate.spec.template.spec.containers[0]) as $c
  | [
      $cj.metadata.name,
      (
        [
          $c.env[]?
          | select(.name == "GHA2DB_AFFILIATIONS_DB")
          | .value
        ][0] // "<unset>"
      )
    ]
  | @tsv
' |
sort |
column -t
```

Every hourly project CronJob must show:

```
GHA2DB_AFFILIATIONS_DB = affiliations
```

Project affiliation CronJobs:

```
kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjobs \
  -l type=affiliations-cron -o json |
jq -r '
  .items[]
  | . as $cj
  | ($cj.spec.jobTemplate.spec.template.spec.containers[0]) as $c
  | [
      $cj.metadata.name,
      (
        [
          $c.env[]?
          | select(.name == "GHA2DB_AFFILIATIONS_DB")
          | .value
        ][0] // "<unset>"
      ),
      (
        [
          $c.env[]?
          | select(.name == "GHA2DB_CHECK_IMPORTED_SHA")
          | .value
        ][0] // "<unset>"
      ),
      (
        [
          $c.env[]?
          | select(.name == "GET_AFFS_FILES")
          | .value
        ][0] // "<unset>"
      )
    ]
  | @tsv
' |
sort |
column -t
```

Expected:

- `GHA2DB_AFFILIATIONS_DB=affiliations`
- `GHA2DB_CHECK_IMPORTED_SHA=` empty
- `GET_AFFS_FILES=` empty

Verify the dedicated importer still exists:

```
kubectl --context "$KUBE_CONTEXT" -n "$NS" get \
  cronjob/devstats-affiliations-import
```

### 3.8 Run representative post-flip sanity checks

```
for db in sam openwhisk gha allprj
do
  if grep -qw "$db" "$LIST"
  then
    sanity_db "$db" || exit 1
  fi
done
```

The required migration-preservation result is zero missing retained local actor rows. Historical event actor IDs that were already absent before migration are informational and are not a migration failure.

### 3.9 Restore prior CronJob suspend states

Only restore schedules after:

- `flip_all_dbs` completed;
- all Helm release upgrades completed;
- environment verification passed;
- representative sanity checks passed.

```
while IFS="$(printf '\t')" read -r cj was_suspended
do
  test -n "$cj" || continue
  echo "Restoring $cj suspend=$was_suspended"

  kubectl --context "$KUBE_CONTEXT" -n "$NS" patch \
    "cronjob/$cj" \
    --type merge \
    -p "{\"spec\":{\"suspend\":$was_suspended}}" || exit 1
done < "$SUSPEND_STATE"
```

Explicitly enable the central importer:

```
kubectl --context "$KUBE_CONTEXT" -n "$NS" patch \
  cronjob/devstats-affiliations-import \
  --type merge \
  -p '{"spec":{"suspend":false}}'
```

Show final states:

```
kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjobs \
  -o custom-columns='NAME:.metadata.name,SUSPEND:.spec.suspend,SCHEDULE:.spec.schedule' |
sort
```

### 3.10 Initial post-cutover error scan

```
pgk psql -X -v ON_ERROR_STOP=1 -P pager=off devstats -c "
  select
    dt,
    prog,
    proj,
    run_dt,
    left(msg, 2000) as msg
  from gha_logs
  where dt >= now() - interval '2 hours'
    and coalesce(msg, '') ~* (
      'postgres_fdw'
      '|foreign table'
      '|foreign server'
      '|user mapping'
      '|password is required'
      '|no password supplied'
      '|could not connect'
      '|permission denied'
      '|on conflict.*not supported'
      '|fatal'
      '|panic'
    )
  order by id;
"
```

Expected: no unexplained rows.

Let all `devstats-test` projects run for approximately one day. Then:

- review scheduled sync failures;
- review project-affiliation Job failures;
- rerun `sanity_db` for several small, medium, and large databases;
- check `gha_logs`;
- check representative company/country dashboards;
- check `allprj` and `gha` separately.

4) Create shared objects on `devstats-prod`:

### 4.1 Initialize production and create the shared database

Run from the `cncf/devstats` repository root:

```
export KUBE_CONTEXT=prod
source ./migration-functions.sh
preamble devstats-prod devel/all_prod_dbs.txt

create_shared
seed
```

`create_shared` must be run only once in this namespace. It aborts if the `affiliations` database already exists.

### 4.2 Deploy the dedicated production central importer release

Set the Helm chart path:

```
CHART="${CHART:-../devstats-helm/devstats-helm}"
test -d "$CHART" || {
  echo "ABORT: Helm chart directory not found: $CHART"
  false
}
```

Start from the production backups release values:

```
EN=prod

helm --kube-context "$KUBE_CONTEXT" -n "$NS" \
  get values "devstats-$EN-backups" -o yaml \
  > /tmp/affs-import-values-prod.yaml
```

Edit `/tmp/affs-import-values-prod.yaml`:

```
remove:
  backupsProdServer
  backupsTestServer

add or set:
  skipBackups: 1
  skipAffiliationsImport: ""
  affiliationsDB: affiliations
  prodServer: 1
  testServer: ""
```

Install the dedicated release:

```
helm --kube-context "$KUBE_CONTEXT" -n "$NS" install \
  "${NS}-affs-import" \
  "$CHART" \
  -f /tmp/affs-import-values-prod.yaml
```

Verify that it created exactly one central importer CronJob:

```
kubectl --context "$KUBE_CONTEXT" -n "$NS" get \
  cronjob/devstats-affiliations-import \
  -o wide
```

### 4.3 Run the initial production reconciliation

```
reconcile "affs-recon-initial-${NS}-$(date +%s)"
maps
```

Verify that the lock was released:

```
pgk psql -X -v ON_ERROR_STOP=1 -P pager=off devstats -c "
  select name, owner, dt
  from gha_locks
  where name = 'affs_lock';
"
```

Expected: zero rows.

Check basic shared-table counts:

```
pgk psql -X -v ON_ERROR_STOP=1 -P pager=off affiliations -c "
  select 'gha_actors' as table_name, count(*) as rows from gha_actors
  union all
  select 'gha_actors_affiliations', count(*) from gha_actors_affiliations
  union all
  select 'gha_actors_emails', count(*) from gha_actors_emails
  union all
  select 'gha_actors_names', count(*) from gha_actors_names
  union all
  select 'gha_companies', count(*) from gha_companies
  union all
  select 'gha_bot_logins', count(*) from gha_bot_logins
  union all
  select 'gha_map_id_to_login', count(*) from gha_map_id_to_login
  union all
  select 'gha_map_login_to_id', count(*) from gha_map_login_to_id
  union all
  select 'gha_map_name_to_login', count(*) from gha_map_name_to_login
  union all
  select 'gha_map_actor_email', count(*) from gha_map_actor_email;
"
```

At this point production project databases are still local and production behavior remains legacy.

5) Pilot on smallest DB on `devstats-prod` (find 2 smallest DBs first, exactly as in `devstats-test`).

### 5.1 Find and record the two smallest production project databases

```
export KUBE_CONTEXT=prod
source ./migration-functions.sh
preamble devstats-prod devel/all_prod_dbs.txt

PILOT_DBS_FILE="/tmp/${NS}-affiliations-pilot-dbs.txt"

pgk psql -X -qAt -v ON_ERROR_STOP=1 -c "
  select datname
  from pg_database
  where datname = any(
    string_to_array('$(cat devel/all_prod_dbs.txt)', ' ')
  )
  order by pg_database_size(datname)
  limit 2;
" | tee "$PILOT_DBS_FILE"

nl -ba "$PILOT_DBS_FILE"
```

Before proceeding, verify that both selected databases have normal hourly and affiliation CronJobs. Do not select `gha` or `allprj` as the first production pilot.

### 5.2 First production pilot

Set the first selected database:

```
db="$(sed -n '1p' "$PILOT_DBS_FILE")"
PROJECT="$db"

# Special mappings, only if one of these was selected:
test "$db" = "gha" && PROJECT=kubernetes
test "$db" = "allprj" && PROJECT=all

SYNC_CJ="devstats-$PROJECT"
AFFS_CJ="devstats-affiliations-$PROJECT"

echo "db=$db"
echo "PROJECT=$PROJECT"
echo "SYNC_CJ=$SYNC_CJ"
echo "AFFS_CJ=$AFFS_CJ"

kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjob \
  "$SYNC_CJ" "$AFFS_CJ"
```

If the CronJob lookup fails, set `PROJECT` to the project key whose `psql_db` is `$db` in `projects.yaml`, then recompute `SYNC_CJ` and `AFFS_CJ`.

Suspend and drain:

```
kubectl --context "$KUBE_CONTEXT" -n "$NS" patch \
  "cronjob/$SYNC_CJ" \
  --type merge \
  -p '{"spec":{"suspend":true}}'

kubectl --context "$KUBE_CONTEXT" -n "$NS" patch \
  "cronjob/$AFFS_CJ" \
  --type merge \
  -p '{"spec":{"suspend":true}}'

wait_project_jobs_drained "$PROJECT"
```

Perform the final pilot sweep:

```
seed
reconcile "affs-recon-${PROJECT}-$(date +%s)"
seed
maps
```

Test socket FDW first:

```
AFFS_FDW_MODE=socket

fdw "$db" "$AFFS_FDW_MODE"
fdw_auth_test "$db"
```

If the socket test succeeds:

```
save_fdw_mode socket
```

Only if the socket test fails with an authentication or connection error, rebuild in password mode:

```
fdw "$db" password
fdw_auth_test "$db"
save_fdw_mode password
```

Load the persisted production decision:

```
load_fdw_mode
echo "Production FDW mode: $AFFS_FDW_MODE"
```

Flip and validate:

```
preamble devstats-prod devel/all_prod_dbs.txt
load_fdw_mode
copy_migration_sql
flip "$db"
sanity_db "$db"
patch_project_cronjobs "$PROJECT"
```

Run one manual hourly sync:

```
PILOT_START="$(
  pgk psql -X -qAt -v ON_ERROR_STOP=1 devstats \
    -c 'select clock_timestamp()::timestamp'
)"

echo "$PILOT_START"

SYNC_JOB="pilot-sync-${PROJECT}-$(date +%s)"
run_cronjob_once "$SYNC_CJ" "$SYNC_JOB"

sanity_db "$db"
show_project_logs "$PROJECT" "2 hours"

pgk psql -X -v ON_ERROR_STOP=1 -P pager=off "$db" -c "
  select max(created_at) as newest_event
  from gha_events;
"
```

Run one manual project affiliation regeneration:

```
AFFS_JOB="pilot-affs-${PROJECT}-$(date +%s)"
run_cronjob_once "$AFFS_CJ" "$AFFS_JOB"

sanity_db "$db"
show_project_logs "$PROJECT" "2 hours"
```

Confirm the project affiliation Job did not run `import_affs`:

```
pgk psql -X -v ON_ERROR_STOP=1 -P pager=off devstats -c "
  select count(*) as project_import_affs_calls
  from gha_logs
  where proj = '$PROJECT'
    and prog = 'import_affs'
    and dt >= '$PILOT_START'::timestamp;
"
```

Expected:

```
0
```

Confirm the shared lock was released:

```
pgk psql -X -v ON_ERROR_STOP=1 -P pager=off devstats -c "
  select name, owner, dt
  from gha_locks
  where name = 'affs_lock';
"
```

Expected: zero rows.

Unsuspend the first pilot:

```
kubectl --context "$KUBE_CONTEXT" -n "$NS" patch \
  "cronjob/$SYNC_CJ" \
  --type merge \
  -p '{"spec":{"suspend":false}}'

kubectl --context "$KUBE_CONTEXT" -n "$NS" patch \
  "cronjob/$AFFS_CJ" \
  --type merge \
  -p '{"spec":{"suspend":false}}'

kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjob \
  "$SYNC_CJ" "$AFFS_CJ" \
  -o custom-columns='NAME:.metadata.name,SUSPEND:.spec.suspend,SCHEDULE:.spec.schedule'
```

### 5.3 Second production pilot

Set the second selected database:

```
db="$(sed -n '2p' "$PILOT_DBS_FILE")"
PROJECT="$db"

test "$db" = "gha" && PROJECT=kubernetes
test "$db" = "allprj" && PROJECT=all

SYNC_CJ="devstats-$PROJECT"
AFFS_CJ="devstats-affiliations-$PROJECT"

echo "db=$db"
echo "PROJECT=$PROJECT"
echo "SYNC_CJ=$SYNC_CJ"
echo "AFFS_CJ=$AFFS_CJ"

kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjob \
  "$SYNC_CJ" "$AFFS_CJ"
```

Suspend and drain:

```
kubectl --context "$KUBE_CONTEXT" -n "$NS" patch \
  "cronjob/$SYNC_CJ" \
  --type merge \
  -p '{"spec":{"suspend":true}}'

kubectl --context "$KUBE_CONTEXT" -n "$NS" patch \
  "cronjob/$AFFS_CJ" \
  --type merge \
  -p '{"spec":{"suspend":true}}'

wait_project_jobs_drained "$PROJECT"
```

Final sweep, FDW setup, and flip using the already-selected production FDW mode:

```
seed
reconcile "affs-recon-${PROJECT}-$(date +%s)"
seed
maps

load_fdw_mode
fdw "$db" "$AFFS_FDW_MODE"
fdw_auth_test "$db"

preamble devstats-prod devel/all_prod_dbs.txt
load_fdw_mode
copy_migration_sql
flip "$db"
sanity_db "$db"
patch_project_cronjobs "$PROJECT"
```

Run one manual sync and one manual affiliation regeneration:

```
PILOT_START="$(
  pgk psql -X -qAt -v ON_ERROR_STOP=1 devstats \
    -c 'select clock_timestamp()::timestamp'
)"

SYNC_JOB="pilot-sync-${PROJECT}-$(date +%s)"
run_cronjob_once "$SYNC_CJ" "$SYNC_JOB"

sanity_db "$db"
show_project_logs "$PROJECT" "2 hours"

AFFS_JOB="pilot-affs-${PROJECT}-$(date +%s)"
run_cronjob_once "$AFFS_CJ" "$AFFS_JOB"

sanity_db "$db"
show_project_logs "$PROJECT" "2 hours"
```

Confirm no project import occurred:

```
pgk psql -X -v ON_ERROR_STOP=1 -P pager=off devstats -c "
  select count(*) as project_import_affs_calls
  from gha_logs
  where proj = '$PROJECT'
    and prog = 'import_affs'
    and dt >= '$PILOT_START'::timestamp;
"
```

Expected:

```
0
```

Unsuspend the second pilot:

```
kubectl --context "$KUBE_CONTEXT" -n "$NS" patch \
  "cronjob/$SYNC_CJ" \
  --type merge \
  -p '{"spec":{"suspend":false}}'

kubectl --context "$KUBE_CONTEXT" -n "$NS" patch \
  "cronjob/$AFFS_CJ" \
  --type merge \
  -p '{"spec":{"suspend":false}}'

kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjob \
  "$SYNC_CJ" "$AFFS_CJ" \
  -o custom-columns='NAME:.metadata.name,SUSPEND:.spec.suspend,SCHEDULE:.spec.schedule'
```

Let both production pilots complete normal scheduled runs. Before the full production cutover, run for each pilot:

```
sanity_db "$db"
show_project_logs "$PROJECT" "24 hours"
```

Also inspect company/country dashboards for both projects.

6) Full switchover for all remaining `devstats-prod` projects.

- Start only after both production pilots have completed their soak.
- The sequence is the same as the test full switchover, but uses the production namespace, production DB list, and the FDW mode selected by the first production pilot.

### 6.1 Initialize and load production FDW mode

```
export KUBE_CONTEXT=prod
source ./migration-functions.sh
preamble devstats-prod devel/all_prod_dbs.txt
load_fdw_mode

echo "NS=$NS"
echo "PRIMARY=$PRIMARY"
echo "AFFS_FDW_MODE=$AFFS_FDW_MODE"

CHART="${CHART:-../devstats-helm/devstats-helm}"
test -d "$CHART" || {
  echo "ABORT: Helm chart directory not found: $CHART"
  false
}
```

### 6.2 Save CronJob states and suspend the entire namespace

```
SUSPEND_STATE="/tmp/${NS}-cronjob-suspend-state.tsv"

kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjobs -o json |
jq -r '
  .items[]
  | [
      .metadata.name,
      ((.spec.suspend // false) | tostring)
    ]
  | @tsv
' > "$SUSPEND_STATE"

cat "$SUSPEND_STATE"

while IFS="$(printf '\t')" read -r cj was_suspended
do
  test -n "$cj" || continue
  echo "Suspending $cj"

  kubectl --context "$KUBE_CONTEXT" -n "$NS" patch \
    "cronjob/$cj" \
    --type merge \
    -p '{"spec":{"suspend":true}}' || exit 1
done < "$SUSPEND_STATE"
```

### 6.3 Drain all active production Jobs

```
while true
do
  active="$(
    kubectl --context "$KUBE_CONTEXT" -n "$NS" get jobs -o json |
    jq '[.items[] | select((.status.active // 0) > 0)] | length'
  )"

  if test "$active" -eq 0
  then
    echo "All active production Jobs drained"
    break
  fi

  echo "Waiting for $active active Job(s):"
  kubectl --context "$KUBE_CONTEXT" -n "$NS" get jobs -o json |
  jq -r '
    .items[]
    | select((.status.active // 0) > 0)
    | [
        .metadata.name,
        (.status.startTime // "-"),
        ((.status.active // 0) | tostring)
      ]
    | @tsv
  '

  sleep 30
done
```

### 6.4 Final production sweep and reconciliation

```
seed
reconcile "affs-recon-full-${NS}-$(date +%s)"
seed
maps
```

Verify the shared lock is absent:

```
pgk psql -X -v ON_ERROR_STOP=1 -P pager=off devstats -c "
  select name, owner, dt
  from gha_locks
  where name = 'affs_lock';
"
```

Expected: zero rows.

### 6.5 Flip all remaining production databases

Refresh the current primary:

```
preamble devstats-prod devel/all_prod_dbs.txt
load_fdw_mode

echo "Current primary: $PRIMARY"
echo "Using FDW mode: $AFFS_FDW_MODE"

flip_all_dbs
```

This validates and skips the two already-flipped production pilot databases.

Do not continue if any project database fails FDW setup, authentication, transactional flip, or post-flip validation.

### 6.6 Persist shared mode in all ordinary production Helm releases

Check for CronJobs without a Helm owner:

```
NO_OWNER="$(
  kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjobs -o json |
  jq '
    [
      .items[]
      | select(
          ((.metadata.labels.type // "") == "cron")
          or
          ((.metadata.labels.type // "") == "affiliations-cron")
        )
      | select(
          (.metadata.annotations["meta.helm.sh/release-name"] // "") == ""
        )
    ]
    | length
  '
)"

if test "$NO_OWNER" -ne 0
then
  echo "ABORT: $NO_OWNER project CronJob(s) have no Helm release owner"
  false
fi
```

Get the ordinary project release list:

```
REGULAR_RELEASES="$(
  kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjobs -o json |
  jq -r '
    .items[]
    | select(.metadata.name != "devstats-affiliations-import")
    | select(
        ((.metadata.labels.type // "") == "cron")
        or
        ((.metadata.labels.type // "") == "affiliations-cron")
      )
    | .metadata.annotations["meta.helm.sh/release-name"]
    | select(. != null and . != "")
  ' |
  sort -u
)"

echo "$REGULAR_RELEASES"

test -n "$REGULAR_RELEASES" || {
  echo "ABORT: no production project CronJob Helm releases found"
  false
}
```

Create production shared-mode overrides:

```
AFFS_FDW_USE_PASSWORD=""
if test "$AFFS_FDW_MODE" = "password"
then
  AFFS_FDW_USE_PASSWORD="1"
fi

OVERRIDES="/tmp/affiliations-cutover-${NS}.yaml"

cat > "$OVERRIDES" <<EOF
affiliationsDB: "affiliations"
checkImportedSHA: ""
affiliationsGetAffsFiles: ""
skipAffiliationsImport: "1"
affsFdwUsePassword: "$AFFS_FDW_USE_PASSWORD"
EOF

cat "$OVERRIDES"
```

Upgrade each ordinary production release:

```
for rel in $REGULAR_RELEASES
do
  VALUES_FILE="/tmp/values-${NS}-${rel}.yaml"

  echo "=== Saving values for $rel"
  helm --kube-context "$KUBE_CONTEXT" -n "$NS" \
    get values "$rel" -o yaml > "$VALUES_FILE" || exit 1

  echo "=== Upgrading $rel"
  helm --kube-context "$KUBE_CONTEXT" -n "$NS" \
    upgrade "$rel" "$CHART" \
    -f "$VALUES_FILE" \
    -f "$OVERRIDES" || exit 1
done
```

The dedicated `${NS}-affs-import` release must not be included in this loop.

### 6.7 Verify production CronJob environments

Hourly CronJobs:

```
kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjobs \
  -l type=cron -o json |
jq -r '
  .items[]
  | . as $cj
  | ($cj.spec.jobTemplate.spec.template.spec.containers[0]) as $c
  | [
      $cj.metadata.name,
      (
        [
          $c.env[]?
          | select(.name == "GHA2DB_AFFILIATIONS_DB")
          | .value
        ][0] // "<unset>"
      )
    ]
  | @tsv
' |
sort |
column -t
```

Every row must end with:

```
affiliations
```

Project affiliation CronJobs:

```
kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjobs \
  -l type=affiliations-cron -o json |
jq -r '
  .items[]
  | . as $cj
  | ($cj.spec.jobTemplate.spec.template.spec.containers[0]) as $c
  | [
      $cj.metadata.name,
      (
        [
          $c.env[]?
          | select(.name == "GHA2DB_AFFILIATIONS_DB")
          | .value
        ][0] // "<unset>"
      ),
      (
        [
          $c.env[]?
          | select(.name == "GHA2DB_CHECK_IMPORTED_SHA")
          | .value
        ][0] // "<unset>"
      ),
      (
        [
          $c.env[]?
          | select(.name == "GET_AFFS_FILES")
          | .value
        ][0] // "<unset>"
      )
    ]
  | @tsv
' |
sort |
column -t
```

Expected:

- shared DB: `affiliations`;
- SHA check: empty;
- file download flag: empty.

### 6.8 Run representative production sanity checks

Run `sanity_db` for:

- both production pilot databases;
- `gha`;
- `allprj`;
- at least one medium-size project.

Example:

```
for db in gha allprj
do
  if grep -qw "$db" "$LIST"
  then
    sanity_db "$db" || exit 1
  fi
done
```

Also rerun `sanity_db` manually for the two values saved in:

```
cat "$PILOT_DBS_FILE"
```

### 6.9 Restore CronJob states and explicitly start the central importer

Restore the pre-cutover suspend state:

```
while IFS="$(printf '\t')" read -r cj was_suspended
do
  test -n "$cj" || continue
  echo "Restoring $cj suspend=$was_suspended"

  kubectl --context "$KUBE_CONTEXT" -n "$NS" patch \
    "cronjob/$cj" \
    --type merge \
    -p "{\"spec\":{\"suspend\":$was_suspended}}" || exit 1
done < "$SUSPEND_STATE"
```

Explicitly unsuspend the central importer:

```
kubectl --context "$KUBE_CONTEXT" -n "$NS" patch \
  cronjob/devstats-affiliations-import \
  --type merge \
  -p '{"spec":{"suspend":false}}'
```

Review all final states:

```
kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjobs \
  -o custom-columns='NAME:.metadata.name,SUSPEND:.spec.suspend,SCHEDULE:.spec.schedule' |
sort
```

### 6.10 Production monitoring immediately after resuming

Check active and failed Jobs:

```
kubectl --context "$KUBE_CONTEXT" -n "$NS" get jobs \
  --sort-by=.metadata.creationTimestamp
```

Search `gha_logs` for FDW and shared-database failures:

```
pgk psql -X -v ON_ERROR_STOP=1 -P pager=off devstats -c "
  select
    dt,
    prog,
    proj,
    run_dt,
    left(msg, 2000) as msg
  from gha_logs
  where dt >= now() - interval '4 hours'
    and coalesce(msg, '') ~* (
      'postgres_fdw'
      '|foreign table'
      '|foreign server'
      '|user mapping'
      '|password is required'
      '|no password supplied'
      '|could not connect'
      '|permission denied'
      '|read-only transaction'
      '|on conflict.*not supported'
      '|deadlock'
      '|statement timeout'
      '|fatal'
      '|panic'
    )
  order by id;
"
```

Check incomplete metric runs after Jobs have finished:

```
with runs as (
  select
    proj,
    run_dt,
    min(dt) as first_log,
    max(dt) as last_log,
    bool_or(msg = 'All done.') as all_done,
    bool_or(msg like 'Time(%') as has_final_time,
    count(*) filter (
      where msg ~* '(error|fatal|panic|failed|pq:)'
    ) as error_lines
  from gha_logs
  where prog = 'calc_metric'
    and dt >= now() - interval '4 hours'
  group by proj, run_dt
)
select
  *,
  last_log - run_dt as elapsed
from runs
where not all_done
   or not has_final_time
   or error_lines > 0
order by run_dt;
```

After the first normal production cycle:

- check `gha`, `allprj`, both pilots, and several medium projects;
- check company/country dashboards;
- compare slow metric durations against pre-cutover samples;
- verify project affiliation Jobs do not run `import_affs`;
- verify only the central importer logs `prog='import_affs'` under `proj='shared'`;
- verify `devstats.gha_locks` has no abandoned `affs_lock`.

N) Other useful functions:
```
# flip_all_dbs
run_cronjob_once <cronjob-name> [job-name]
show_project_logs <project-key> [interval]
```
