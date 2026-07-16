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

- Save current CJ suspend states, suspend all CJs, drain all active jobs.
```
export KUBE_CONTEXT=test
source ./migration-functions.sh
preamble devstats-test devel/all_test_dbs.txt
load_fdw_mode

seed
reconcile "affs-recon-full-test-$(date +%s)"
seed
maps

preamble devstats-test devel/all_test_dbs.txt
load_fdw_mode
copy_migration_sql
flip_all_dbs
```
- Upgrade every release owning `type=cron`/`affiliations-cron` CJs, preserving its values, with:
```
affiliationsDB=affiliations
checkImportedSHA=''
affiliationsGetAffsFiles=''
skipAffiliationsImport=1
affsFdwUsePassword=1  # password mode only
```
- Do not include the dedicated affs-import release.
- Verify CJ envs, restore previous suspend states, explicitly unsuspend `devstats-affiliations-import`.
- Run `sanity_db` on pilots, `gha`, `allprj`, and several normal DBs; check logs/dashboards; soak for 1 day.

4) Create shared objects on `devstats-prod`:

```
export KUBE_CONTEXT=prod
source ./migration-functions.sh
preamble devstats-prod devel/all_prod_dbs.txt
create_shared
seed
```
- Repeat IMPORT-CJ setup from point 1 with:
```
EN=prod
prodServer: 1
testServer: ''
```
- Then:
```
reconcile "affs-recon-initial-prod-$(date +%s)"
```

5) Pilot on smallest DBs on `devstats-prod`.

- Find two smallest:
```
pgk psql -tAc "select datname from pg_database where datname = any(string_to_array('$(cat devel/all_prod_dbs.txt)',' ')) order by pg_database_size(datname) limit 2"
```
- Repeat point 2 for the first DB.
- Test socket mode first; save it when successful, otherwise rebuild/test/save password mode.
- Repeat point 2 for the second DB using `load_fdw_mode`.
- Let both run for 1 day; check `sanity_db`, `gha_logs`, jobs, and dashboards.

6) Full switchover for all remaining `devstats-prod` projects.

- Repeat point 3 with:
```
export KUBE_CONTEXT=prod
preamble devstats-prod devel/all_prod_dbs.txt
```
- Use production Helm releases and the production saved FDW mode.
- After resuming: check pilots, `gha`, `allprj`, several medium DBs, `gha_logs`, jobs, locks, and dashboards.


7) Other useful functions:
```
# flip_all_dbs
run_cronjob_once <cronjob-name> [job-name]
show_project_logs <project-key> [interval]
```
