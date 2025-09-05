# Steps needed to graduate project

Those steps are generally needed to change project status (usually from `Incubating` to `Graduated` or from `Sandbox` to `Incubating`):

- Update status to `Archived` `projects.yaml`, add `archived_date`. Remove its orgs/repos from `All CNCF`.
- Refer to [this](https://docs.google.com/spreadsheets/d/10-rSBsSMQZD6nCLBkyKfeU4kdffB4bOSV0NnZqF5bBk/edit#gid=1632287387) and/or issues on [cncf/toc](https://github.com/cncf/toc) repo.
- Change projects links all home dashboards. Take for example `grafana/dashboards/all/dashboards.json`, copy list of projects links into `FROM` file, change order accordingly and paste it into `TO` file.
- Run: `./devel/dashboards_replace_from_to.sh dashboards.json`.
- Consider updating `all/psql.sh` and `scripts/all/repo_groups.sql` - we currently don't remove archived projects from those files.
- Update files: `partials/projects.html partials/projects_health.html metrics/all/sync_vars.yaml apache/www/index_prod.html apache/www/index_test.html` (remember about `cncf-` classes/separators). Look for `/\cdevstats projects:\|projects:\|graduated:\|incubating:\|sandbox:` - update counts.
- Update projects counts (graduated, incubating, sandbox, archived) in `apache/www/index_*.html`, `partials/projects_health.html` and `partials/projects.html` files.
- For updating `partials/projects.html` or `apache/www/index_*.html`, copy the Graduated/Incubating/Sandbox section into some text file and then `KIND=Graduated SIZE=9 ./tsplit < graduated.txt > new_graduated.txt`.
- You only need to move projects that changed state to that text file, and then it will take care of right/left/bottom separators and dividing into columns/rows.
- Update test and production www index files: `apache/www/index_test.html apache/www/index_prod.html`. Possibly others too like for GraphQL.
- Update `apache/*/sites-enabled/* apache/*/sites.txt` files.
- To do this you can copy `prod`/`test` section from already modified `partials/projects.html` and then do the following replacements:
- `` :'<,'>s/\[\[hostname]]/teststats.cncf.io/g `` or `` :'<,'>s/\[\[hostname]]/devstats.cncf.io/g ``, followed by `` :'<,'>s/public\/img\/projects\///g ``.
- See `Update shared Grafana data` in `ADDING_NEW_PROJECT.md`.
- Regenerate `devstats-docker-images`: `head images/build_images.sh` and build all images.
