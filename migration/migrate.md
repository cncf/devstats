1) First create shared objects on `devstats-test`:
```
export KUBE_CONTEXT=test
source ./migration-functions.sh
preamble devstats-test devel/all_test_dbs.txt
create_shared
seed
EN=test
helm -n "$NS" get values devstats-$EN-backups -o yaml > /tmp/affs-import-values.yaml
vim /tmp/affs-import-values.yaml
# edit /tmp/affs-import-values.yaml:
#   remove: backupsProdServer, backupsTestServer
#   add:    skipBackups: 1
#           skipAffiliationsImport: ''
#           affiliationsDB: affiliations
#           prodServer: ''
#           testServer: 1
cd ../devstats-helm/
helm -n "$NS" install "${NS}-affs-import" ./devstats-helm -f /tmp/affs-import-values.yaml
cd ../devstats/
kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjob devstats-affiliations-import
reconcile
```


2) Pilot on smallest DB - sam, openwhisk (on devstats-test):
- Get smallest candidates: `pgk psql -tAc "select datname from pg_database where datname = any(string_to_array('$(cat devel/all_test_dbs.txt)',' ')) order by pg_database_size(datname) limit 2"` -> sam, openwhisk.
```
export KUBE_CONTEXT=test
source ./migration-functions.sh
preamble devstats-test devel/all_test_dbs.txt
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
load_fdw_mode
fdw "$db" "$AFFS_FDW_MODE"
fdw_auth_test "$db"
save_fdw_mode "$AFFS_FDW_MODE"
copy_migration_sql
flip "$db"
sanity_db "$db"
patch_project_cronjobs $PROJECT
# rollback_db $db
```
- Now do some 1st time passes/tests:
```
PILOT_START="$(pgk psql -X -qAt -v ON_ERROR_STOP=1 devstats -c 'select clock_timestamp()::timestamp')"
echo "$PILOT_START"
SYNC_JOB="pilot-sync-${PROJECT}-$(date +%s)"
echo "$SYNC_CJ $SYNC_JOB"
run_cronjob_once "$SYNC_CJ" "$SYNC_JOB"
sanity_db "$db"
show_project_logs "$PROJECT" "2 hours"
pgk psql -X -v ON_ERROR_STOP=1 -P pager=off "$db" -c "select max(created_at) as newest_event from gha_events"
AFFS_JOB="pilot-affs-${PROJECT}-$(date +%s)"
echo "$AFFS_CJ $AFFS_JOB"
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
export KUBE_CONTEXT=test
source ./migration-functions.sh
preamble devstats-test devel/all_test_dbs.txt
db=openwhisk
sanity_db $db
show_project_logs $db "24 hours"
```


3) Full switchover for all remaining `devstats-test` projects.
```
export KUBE_CONTEXT=test
source ./migration-functions.sh
preamble devstats-test devel/all_test_dbs.txt
load_fdw_mode

SUSPEND_STATE="/tmp/${NS}-cronjob-suspend-state.tsv"
kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjobs -o json | jq -r '.items[] | [.metadata.name, ((.spec.suspend // false) | tostring)] | @tsv' > "$SUSPEND_STATE"
while IFS=$'\t' read -r cj old; do
  kubectl --context "$KUBE_CONTEXT" -n "$NS" patch "cronjob/$cj" --type merge -p '{"spec":{"suspend":true}}' || exit 1
done < "$SUSPEND_STATE"
while [ "$(kubectl --context "$KUBE_CONTEXT" -n "$NS" get jobs -o json | jq '[.items[] | select((.status.active // 0) > 0)] | length')" != "0" ]; do sleep 30; done

# Namespace-wide final sweep: seed already loops over every still-local DB.
seed
reconcile "affs-recon-full-test-$(date +%s)" 1>reconcile.log 2>reconcile.err < /dev/null &
kubectl get po -n "$NS" | grep affs-recon-full-test
tail -f reconcile.???
seed
maps

# Per remaining DB: fdw -> fdw_auth_test -> transactional flip/validation.
preamble devstats-test devel/all_test_dbs.txt
flip_all_dbs
update_k_cjs
# update_h_cjs "$KUBE_CONTEXT"
```
- Run `sanity_db` on a few non-pilot DBs that were just switched over, for example `cii`, `linux`.
- Restore CJs status:
```
while IFS=$'\t' read -r cj old; do
  [ -n "$cj" ] || continue
  kubectl --context "$KUBE_CONTEXT" -n "$NS" patch \
    "cronjob/$cj" \
    --type merge \
    -p "{\"spec\":{\"suspend\":$old}}" || exit 1
done < "$SUSPEND_STATE"
kubectl --context "$KUBE_CONTEXT" -n "$NS" patch cronjob/devstats-affiliations-import --type merge -p '{"spec":{"suspend":false}}'
kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjobs -o custom-columns='NAME:.metadata.name,SUSPEND:.spec.suspend,SCHEDULE:.spec.schedule' | sort
```


4) Create shared objects on `devstats-prod`:

```
export KUBE_CONTEXT=prod
source ./migration-functions.sh
preamble devstats-prod devel/all_prod_dbs.txt
create_shared
seed
EN=prod
helm -n "$NS" get values devstats-$EN-backups -o yaml > /tmp/affs-import-values.yaml
vim /tmp/affs-import-values.yaml
# edit /tmp/affs-import-values.yaml:
#   remove: backupsProdServer, backupsTestServer
#   add:    skipBackups: 1
#           skipAffiliationsImport: ''
#           affiliationsDB: affiliations
#           prodServer: 1
#           testServer: ''
cd ../devstats-helm/
helm -n "$NS" install "${NS}-affs-import" ./devstats-helm -f /tmp/affs-import-values.yaml
cd ../devstats/
kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjob devstats-affiliations-import
reconcile "affs-recon-initial-prod-$(date +%s)" 1>reconcile.log 2>reconcile.err < /dev/null &
kubectl get po -n "$NS" | grep affs-recon-initial-prod
tail -f reconcile.???
```


5) Pilot on smallest DBs on `devstats-prod`.

- Find two smallest:
```
pgk psql -tAc "select datname from pg_database where datname = any(string_to_array('$(cat devel/all_prod_dbs.txt)',' ')) order by pg_database_size(datname) limit 3" -> kubeelasti, cohdi, modelpack.
PROJECT=kubeelasti
db=kubeelasti
SYNC_CJ="devstats-$PROJECT"
AFFS_CJ="devstats-affiliations-$PROJECT"
kubectl --context "$KUBE_CONTEXT" -n "$NS" patch "cronjob/$SYNC_CJ" --type merge -p '{"spec":{"suspend":true}}'
kubectl --context "$KUBE_CONTEXT" -n "$NS" patch "cronjob/$AFFS_CJ" --type merge -p '{"spec":{"suspend":true}}'
wait_project_jobs_drained "$PROJECT"
seed
reconcile "affs-recon-pilot-prod-$(date +%s)" 1>reconcile.log 2>reconcile.err < /dev/null &
kubectl get po -n "$NS" | grep affs-recon-pilot-prod
tail -f reconcile.???
seed
maps
# load_fdw_mode
# fdw "$db" "$AFFS_FDW_MODE"
fdw $db
fdw_auth_test "$db"
# save_fdw_mode "$AFFS_FDW_MODE"
save_fdw_mode socket
load_fdw_mode
copy_migration_sql
flip "$db"
sanity_db "$db"
patch_project_cronjobs $PROJECT
# rollback_db $db
PILOT_START="$(pgk psql -X -qAt -v ON_ERROR_STOP=1 devstats -c 'select clock_timestamp()::timestamp')"
echo "$PILOT_START"
SYNC_JOB="pilot-sync-${PROJECT}-$(date +%s)"
echo "$SYNC_CJ $SYNC_JOB"
run_cronjob_once "$SYNC_CJ" "$SYNC_JOB"
sanity_db "$db"
show_project_logs "$PROJECT" "2 hours"
pgk psql -X -v ON_ERROR_STOP=1 -P pager=off "$db" -c "select max(created_at) as newest_event from gha_events"
AFFS_JOB="pilot-affs-${PROJECT}-$(date +%s)"
echo "$AFFS_CJ $AFFS_JOB"
run_cronjob_once "$AFFS_CJ" "$AFFS_JOB"
pgk psql -X -v ON_ERROR_STOP=1 -P pager=off devstats -c "select name, owner, dt from gha_locks where name = 'affs_lock'"
kubectl --context "$KUBE_CONTEXT" -n "$NS" patch "cronjob/$SYNC_CJ" --type merge -p '{"spec":{"suspend":false}}'
kubectl --context "$KUBE_CONTEXT" -n "$NS" patch "cronjob/$AFFS_CJ" --type merge -p '{"spec":{"suspend":false}}'
kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjob "$SYNC_CJ" "$AFFS_CJ" -o custom-columns='NAME:.metadata.name,SUSPEND:.spec.suspend,SCHEDULE:.spec.schedule'
```
- Check after one day:
```
export KUBE_CONTEXT=prod
source ./migration-functions.sh
preamble devstats-prod devel/all_prod_dbs.txt
db=kubeelasti
sanity_db $db
show_project_logs $db "24 hours"
```


6) Full switchover for all remaining `devstats-prod` projects.
```
export KUBE_CONTEXT=prod
source ./migration-functions.sh
preamble devstats-prod devel/all_prod_dbs.txt
load_fdw_mode

SUSPEND_STATE="/tmp/${NS}-cronjob-suspend-state.tsv"
kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjobs -o json | jq -r '.items[] | [.metadata.name, ((.spec.suspend // false) | tostring)] | @tsv' > "$SUSPEND_STATE"
while IFS=$'\t' read -r cj old; do
  kubectl --context "$KUBE_CONTEXT" -n "$NS" patch "cronjob/$cj" --type merge -p '{"spec":{"suspend":true}}' || exit 1
done < "$SUSPEND_STATE"
while [ "$(kubectl --context "$KUBE_CONTEXT" -n "$NS" get jobs -o json | jq '[.items[] | select((.status.active // 0) > 0)] | length')" != "0" ]; do sleep 30; done

# Namespace-wide final sweep: seed already loops over every still-local DB.
seed
reconcile "affs-recon-full-prod-$(date +%s)" 1>reconcile.log 2>reconcile.err < /dev/null &
kubectl get po -n "$NS" | grep affs-recon-full-prod
tail -f reconcile.???
seed
maps

flip_all_dbs 1>flip.log 2>flip.err < /dev/null &
tail -f flip.???
update_k_cjs
# kubectl -n devstats-prod set env cj --selector='type=cron' GHA2DB_AFFILIATIONS_DB=affiliations
# kubectl -n devstats-prod set env cj --selector='type=affiliations-cron' GHA2DB_AFFILIATIONS_DB=affiliations GHA2DB_CHECK_IMPORTED_SHA= GET_AFFS_FILES=
```
- Run `sanity_db` on a few non-pilot DBs that were just switched over, for example `gha`, `allprj`, `grpc`, `opentelemetry`, `cohdi`, `modelpack`.
- Restore CJs status:
```
while IFS=$'\t' read -r cj old; do
  [ -n "$cj" ] || continue
  kubectl --context "$KUBE_CONTEXT" -n "$NS" patch \
    "cronjob/$cj" \
    --type merge \
    -p "{\"spec\":{\"suspend\":$old}}" || exit 1
done < "$SUSPEND_STATE"
kubectl --context "$KUBE_CONTEXT" -n "$NS" patch cronjob/devstats-affiliations-import --type merge -p '{"spec":{"suspend":false}}'
kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjobs -o custom-columns='NAME:.metadata.name,SUSPEND:.spec.suspend,SCHEDULE:.spec.schedule' | sort
```
- After resuming: check pilots, `gha`, `allprj`, several medium DBs, `gha_logs`, jobs, locks, and dashboards.


7) Final cleanup and steady state.

- Existing releases are updated by `update_k_cjs`. Future releases use the shared affiliations settings from `devstats-helm/values.yaml`; no extra affiliations Helm arguments are needed.
- After the rollback window closes, suspend/drain CJs and finalize each environment:
```
# test
export KUBE_CONTEXT=test
source ./migration-functions.sh
preamble devstats-test devel/all_test_dbs.txt
confirm_all_migrations

# prod
export KUBE_CONTEXT=prod
source ./migration-functions.sh
preamble devstats-prod devel/all_prod_dbs.txt
confirm_all_migrations
```
- This is irreversible: it drops all `*_pre_fdw` rollback tables and runs `VACUUM FULL ANALYZE`. Run during a maintenance window with sufficient temporary disk space.


8) Other useful functions:
```
# flip_all_dbs
run_cronjob_once <cronjob-name> [job-name]
show_project_logs <project-key> [interval]
confirm_ok_migration <db>
confirm_all_migrations
```
