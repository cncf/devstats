# Adding new org to a project

When project joins CNCF it usually moves from some company-based repo (or set of repos) into its own GitHub org, to update DevStats to reflect this, please do the following:
- You can lookup for all references to the old org by running `` find.sh . '*' old-org > ../out `` while in `~/go/src/github.com/cncf` directory (where you cloned all devstats, gitdm, velocity related CNCF repos. This is optional, you can also follow next steps listed here.
- In `devstats` repo, update the following files (replace `proj` with given project name):
  - `proj/psql.sh metrics/proj/vars.yaml grafana/dashboards/proj/stars-and-forks-by-repository.json scripts/proj/repo_groups.sql`.
  - `util_data/project_cmdline.txt util_data/project_re.txt util_sh/affs_prod.sh util_sh/affs_test.sh projects.yaml scripts/all/repo_groups.sql all/psql.sh devel/deploy_all.sh`.
  - `partials/projects*.html apache/www/index_????.html apache/????/sites.txt`.
- If project was renamed then keep its old lower name/slug everywhere and only update human-readable name/`full_name`, also add mappings like `oldslug: newslug` where `Projects health` is calculated:
  - `` vim metrics/all/metrics.yaml metrics/all/metrics_affs.yaml metrics/all/health.yaml metrics/all/health_all.yaml metrics/all/metrics_retry.yaml ./devel/test_metrics_health.yaml ``.
- In `devstats-docker-images` update: `` vim devstats-helm/projects.yaml ``.
- In `devstats-helm` update: `` vim devstats-helm/values.yaml ``.
- In `velocity` update: `` vim BigQuery/velocity_cncf.sql BigQuery/velocity_lf.sql map/ranges_sane.csv map/urls.csv map/hints.csv map/defmaps.csv ``.
- Consider artwork updates check `ARTWORK.md`.
- Go to `devstats-docker-images` and build new images, check output of: `` head images/build_images.sh ``.
- Check `ADDING_NEW_PROJECT.md` in `devstats` follow instructions from `Update shared Grafana data`, especially: `Do all/everything command`.
- check `ADD_ORG_REPO.md` in `devstats-helm` to backfill the data.
