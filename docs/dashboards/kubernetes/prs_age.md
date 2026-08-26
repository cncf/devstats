<p style="background-color:#4a3200;border:1px solid orange;color:#ffd;padding:8px;">&#9888;&#65039; <b>Data accuracy warning:</b> DevStats uses the public <a href="https://www.gharchive.org" target="_blank">GH Archive</a> dataset, which is missing a significant number of GitHub events (notably in recent months), so contributions data shown here is undercounted. Please do not treat those numbers as 100% accurate or complete, see <a href="https://github.com/cncf/devstats/issues/147" target="_blank">cncf/devstats#147</a> for details.</p>
<h1 id="kubernetes-dashboard">[[full_name]] Open PR Age By Repository Group dashboard</h1>
<p>Links:</p>
<ul>
<li>Metric (repository groups) <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/prs_age.sql" target="_blank">SQL file</a>.</li>
<li>Metric (repositories) <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/prs_age_repos.sql" target="_blank">SQL file</a>.</li>
<li>TSDB <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/metrics.yaml" target="_blank">series definition</a>. Search for <code>prs_age</code></li>
<li>Grafana dashboard <a href="https://github.com/cncf/devstats/blob/master/grafana/dashboards/kubernetes/open-pr-age-by-repository-group.json" target="_blank">JSON</a>.</li>
</ul>
<h1 id="description">Description</h1>
<ul>
<li>This dashboard shows the chart of how many PRs were open in selected periods and what was the median PR open to merge time.</li>
<li>You can select single repository group or summary for all of them (for the top panels related to repository groups).</li>
<li>You can select repository for bottom panels showing per single repository statistics.</li>
<li>You can select PRs with a specific <code>kind/*</code> label or summary for all of them.</li>
<li>Selecting period (for example week) means that dashboard will show number of open PRs and median open to merge time in those periods.</li>
<li>See <a href="https://github.com/cncf/devstats/blob/master/docs/periods.md" target="_blank">here</a> for more informations about periods.</li>
<li>See <a href="https://github.com/cncf/devstats/blob/master/docs/repository_groups.md" target="_blank">here</a> for more informations about repository groups.</li>
</ul>
