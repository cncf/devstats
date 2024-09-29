<h1 id="dashboard-header">[[full_name]] project country statistics cumulative dashboard</h1>
<p>Links:</p>
<ul>
<li>Metric <a href="https://github.com/cncf/devstats/blob/master/metrics/all/project_countries.sql" target="_blank">SQL file</a>.</li>
<li>Committers metric <a href="https://github.com/cncf/devstats/blob/master/metrics/all/project_countries_commiters.sql" target="_blank">SQL file</a>.</li>
<li>TSDB <a href="https://github.com/cncf/devstats/blob/master/metrics/all/metrics.yaml" target="_blank">series definition</a>. Search for <code>project_countries</code></li>
<li>Grafana dashboard <a href="https://github.com/cncf/devstats/blob/master/grafana/dashboards/all/project-country-statistics-cumulative.json" target="_blank">JSON</a>.</li>
</ul>
<h1 id="description">Description</h1>
<ul>
<li>This dashboard shows projects countries statistics (quarterly cumulative).</li>
<li>Contributor is defined as somebody who made a review, comment, commit, created PR or issue.</li>
<li>Contribution is a review, comment, commit, issue or PR.</li>
<li>We are determining contributor's country by using GitHub localization and searching for a country using <a href="http://www.geonames.org" target="_blank">geonames</a> database.</li>
<li>You can select one, multiple or all countries to generate statistics for, quarter, year. Countries are displayed in order of top contributing ones.</li>
<li>You can select one, multiple or all projects to be displayed (stacked, line chart and 100% stacked). Projects are displayed in order of top contributing ones.</li>
<li>By default it generates statistics for top 10 projects in top 10 countries.</li>
<li>You can choose to display contributors, contributions, users, issues, PRs, actvity, committers, commits etc.</li>
<li>See <a href="https://github.com/cncf/devstats/blob/master/docs/repository_groups.md" target="_blank">here</a> for more informations about repository groups (projects).</li>
<li>We are skipping bots activity, see <a href="https://github.com/cncf/devstats/blob/master/docs/excluding_bots.md" target="_blank">excluding bots</a> for details.</li>
</ul>
