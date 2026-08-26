<p style="background-color:#4a3200;border:1px solid orange;color:#ffd;padding:8px;">&#9888;&#65039; <b>Data accuracy warning:</b> DevStats uses the public <a href="https://www.gharchive.org" target="_blank">GH Archive</a> dataset, which is missing a significant number of GitHub events (notably in recent months), so contributions data shown here is undercounted. Please do not treat those numbers as 100% accurate or complete, see <a href="https://github.com/cncf/devstats/issues/147" target="_blank">cncf/devstats#147</a> for details.</p>
<h1 id="kubernetes-ghstats-dashboard">[[full_name]] GitHub stats dashboard (PR commenters)</h1>
<p>Links:</p>
<ul>
<li>Repository groups version metric <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/github_stats_by_repo_groups.sql" target="_blank">SQL file</a>.</li>
<li>Repositories version metric <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/github_stats_by_repos.sql" target="_blank">SQL file</a>.</li>
<li>TSDB <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/metrics.yaml" target="_blank">series definition</a>. Search for <code>github_stats_by_repo</code></li>
<li>Grafana dashboard <a href="https://github.com/cncf/devstats/blob/master/grafana/dashboards/kubernetes/github-stats-by-repository-group.json" target="_blank">JSON</a> (repository groups version).</li>
<li>Grafana dashboard <a href="https://github.com/cncf/devstats/blob/master/grafana/dashboards/kubernetes/github-stats-by-repository.json" target="_blank">JSON</a> (repositories version).</li>
<li>Developer <a href="https://github.com/cncf/devstats/blob/master/docs/dashboards/kubernetes/ghstats_devel.md" target="_blank">documentation</a>.</li>
</ul>
<h1 id="description">Description</h1>
<ul>
<li>This documentations only refers to <code>PR commenters</code> statistic.</li>
<li>This dashboard shows the number of distinct PR commenters for a selected repository or repository group.</li>
<li>You can select multiple repositories or repository groups to stack them.</li>
<li>You can filter by repository or repository group and period.</li>
<li>Selecting period (for example week) means that dahsboard will distinct PR commenters in this period.</li>
<li>See <a href="https://github.com/cncf/devstats/blob/master/docs/periods.md" target="_blank">here</a> for more informations about periods.</li>
<li>See <a href="https://github.com/cncf/devstats/blob/master/docs/repository_groups.md" target="_blank">here</a> for more informations about repository groups.</li>
<li>We are skipping bots when calculating number of commenters, see <a href="https://github.com/cncf/devstats/blob/master/docs/excluding_bots.md" target="_blank">excluding bots</a> for details.</li>
</ul>

