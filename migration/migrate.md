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

[TODO]

4) Create shared objects on `devstats-prod`:

[TODO]

5) Pilot on smallest DB on `devstats-prod` (find 2 smallest DBs first, exactly as in `devstats-test`).

[TODO]

6) Full switchover for all remaining `devstats-prod` projects.

[TODO]

N) Other useful functions:
```
# flip_all_dbs
run_cronjob_once <cronjob-name> [job-name]
show_project_logs <project-key> [interval]
```
