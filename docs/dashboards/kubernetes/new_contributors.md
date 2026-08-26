<p style="background-color:#4a3200;border:1px solid orange;color:#ffd;padding:8px;">&#9888;&#65039; <b>Data accuracy warning:</b> DevStats uses the public <a href="https://www.gharchive.org" target="_blank">GH Archive</a> dataset, which is missing a significant number of GitHub events (notably in recent months), so contributions data shown here is undercounted. Please do not treat those numbers as 100% accurate or complete, see <a href="https://github.com/cncf/devstats/issues/147" target="_blank">cncf/devstats#147</a> for details.</p>
<h1 id="dashboard-header">[[full_name]] new contributors table dashboard</h1>
<p>Links:</p>
<ul>
<li>New contributors metric (repo groups) <a href="https://github.com/cncf/devstats/blob/master/metrics/shared/new_contributors_data.sql" target="_blank">SQL file</a>.</li>
<li>New contributors metric (repos) <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/new_contributors_data_repos.sql" target="_blank">SQL file</a>.</li>
<li>TSDB <a href="https://github.com/cncf/devstats/blob/master/metrics/shared/metrics.yaml" target="_blank">series definition</a>. Search for <code>New contributors table</code></li>
<li>Grafana dashboard <a href="https://github.com/cncf/devstats/blob/master/grafana/dashboards/[[lower_name]]/new-contributors-table.json" target="_blank">JSON</a>.</li>
</ul>
<h1 id="description">Description</h1>
<ul>
<li>This dashboard shows statistics about new PR contributors.</li>
<li>New contributor (PR creator) is someone whose PR was merged for the first time.</li>
<li>You can select single repository group or summary for all of them (for the top panel).</li>
<li>You can select repository for bottom panel showing per single repository statistics.</li>
<li>You can select date range to show new contributors for this period.</li>
<li>See <a href="https://github.com/cncf/devstats/blob/master/docs/repository_groups.md" target="_blank">here</a> for more informations about repository groups.</li>
</ul>
