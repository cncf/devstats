<p style="background-color:#4a3200;border:1px solid orange;color:#ffd;padding:8px;">&#9888;&#65039; <b>Data accuracy warning:</b> DevStats uses the public <a href="https://www.gharchive.org" target="_blank">GH Archive</a> dataset, which is missing a significant number of GitHub events (notably in recent months), so contributions data shown here is undercounted. Please do not treat those numbers as 100% accurate or complete, see <a href="https://github.com/cncf/devstats/issues/147" target="_blank">cncf/devstats#147</a> for details.</p>
<h1 id="kubernetes-dashboard">[[full_name]] Issues age by SIG and repository groups dashboard</h1>
<p>Links:</p>
<ul>
<li>Metric (repo groups) <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/issues_age.sql" target="_blank">SQL file</a>.</li>
<li>Metric (repositories) <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/issues_age_repos.sql" target="_blank">SQL file</a>.</li>
<li>TSDB <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/metrics.yaml" target="_blank">series definition</a>. Search for <code>issues_age</code></li>
<li>Grafana dashboard <a href="https://github.com/cncf/devstats/blob/master/grafana/dashboards/kubernetes/issues-age-by-sig-and-repository-groups.json" target="_blank">JSON</a>.</li>
</ul>
<h1 id="description">Description</h1>
<ul>
<li>This dashboard shows the chart of how many issues were open in selected periods and what was the median issue open to close time.</li>
<li>Issue SIG is determined by <code>sig/*</code> labels. You can also select summary for all issues by choosing <code>All</code> SIG.</li>
<li>Issue kind is determined by <code>kind/*</code> labels. You can also select summary for all issues by choosing <code>All</code> kind.</li>
<li>Issue priority is determined by <code>priority/*</code> labels. You can also select summary for all issues by choosing <code>All</code> priority.</li>
<li>You can select single repository group or summary for all of them (for top/repo group panels).</li>
<li>You can select repository for bottom/repository panels showing per single repository statistics.</li>
<li>Selecting period (for example week) means that dashboard will show number of open issues and median close time in those periods.</li>
<li>See <a href="https://github.com/cncf/devstats/blob/master/docs/periods.md" target="_blank">here</a> for more informations about periods.</li>
<li>See <a href="https://github.com/cncf/devstats/blob/master/docs/repository_groups.md" target="_blank">here</a> for more informations about repository groups.</li>
</ul>
