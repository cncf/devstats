<p style="background-color:#4a3200;border:1px solid orange;color:#ffd;padding:8px;">&#9888;&#65039; <b>Data accuracy warning:</b> DevStats uses the public <a href="https://www.gharchive.org" target="_blank">GH Archive</a> dataset, which is missing a significant number of GitHub events (notably in recent months), so contributions data shown here is undercounted. Please do not treat those numbers as 100% accurate or complete, see <a href="https://github.com/cncf/devstats/issues/147" target="_blank">cncf/devstats#147</a> for details.</p>
<h1 id="kubernetes-dashboard">[[full_name]] Issues Opened/Closed by SIG dashboard</h1>
<p>Links:</p>
<ul>
<li>Opened issues metric <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/labels_sig_kind.sql" target="_blank">SQL file</a>.</li>
<li>Opened issues metric (repositories) <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/labels_sig_kind_repos.sql" target="_blank">SQL file</a>.</li>
<li>Closed issues metric <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/labels_sig_kind_closed.sql" target="_blank">SQL file</a>.</li>
<li>Closed issues metric (repositories) <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/labels_sig_kind_closed_repos.sql" target="_blank">SQL file</a>.</li>
<li>TSDB <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/metrics.yaml" target="_blank">series definition</a>. Search for <code>Issues opened</code></li>
<li>Grafana dashboard <a href="https://github.com/cncf/devstats/blob/master/grafana/dashboards/kubernetes/issues-opened-closed-by-sig.json" target="_blank">JSON</a>.</li>
</ul>
<h1 id="description">Description</h1>
<ul>
<li>This dashboard shows the chart of how many issues were opened and closed in selected periods.</li>
<li>You can filter by SIG and kind.</li>
<li>Issue SIG is determined by <code>sig/*</code> labels. You can also select summary for all issues by choosing <code>All</code> SIG.</li>
<li>Issue kind is determined by <code>kind/*</code> labels. You can also select summary for all issues by choosing <code>All</code> kind.</li>
<li>Selecting period (for example week) means that dashboard will show number of issues in those periods.</li>
<li>See <a href="https://github.com/cncf/devstats/blob/master/docs/periods.md" target="_blank">here</a> for more informations about periods.</li>
<li>You can select repository for bottom panel showing per single repository statistics.</li>
</ul>
