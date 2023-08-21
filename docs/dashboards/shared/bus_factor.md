<h1 id="dashboard-header">[[full_name]] bus factor in repository groups dashboard</h1>
<p>Links:</p>
<ul>
<li>Metric <a href="https://github.com/cncf/devstats/blob/master/metrics/shared/bus_factor.sql" target="_blank">SQL file</a>.</li>
<li>TSDB <a href="https://github.com/cncf/devstats/blob/master/metrics/all/metrics.yaml" target="_blank">series definition</a>. Search for <code>bus_factor</code></li>
<li>Grafana dashboard <a href="https://github.com/cncf/devstats/blob/master/grafana/dashboards/[[lower_name]]/bus-factor-in-repository-groups.json" target="_blank">JSON</a>.</li>
</ul>
<h1 id="description">Description</h1>
<ul>
<li>This dashboard show bus factor and top 10 companies/contributors data for a given repository group and metric combination.</li>
<li>You can choose between organizations/companies and users/contributors bus factor/top 10 stats.</li>
<li>Bus factor value for a selected repository group/project is a minimal number of companies/contributors that contribute to >50% of all contributions of given type.</li>
<li>It also displays companies/users who contribute to a bus factor and top 10 and percentage value of those contributions plus percentage and counts of the remaining contributors/organizations.</li>
<li>You can select last day, month, week etc. range or date range between releases, for example <code>v1.9 - v1.10</code>.</li>
<li>See <a href="https://github.com/cncf/devstats/blob/master/docs/periods.md" target="_blank">here</a> for more informations about periods.</li>
<li>We are skipping bots activity, see <a href="https://github.com/cncf/devstats/blob/master/docs/excluding_bots.md" target="_blank">excluding bots</a> for details.</li>
</ul>
