<p style="background-color:#4a3200;border:1px solid orange;color:#ffd;padding:8px;">&#9888;&#65039; <b>Data accuracy warning:</b> DevStats uses the public <a href="https://www.gharchive.org" target="_blank">GH Archive</a> dataset, which is missing a significant number of GitHub events (notably in recent months), so contributions data shown here is undercounted. Please do not treat those numbers as 100% accurate or complete, see <a href="https://github.com/cncf/devstats/issues/147" target="_blank">cncf/devstats#147</a> for details.</p>
<h1 id="kubernetes-dashboard">[[full_name]] Awaiting PRs by SIG (and repository) dashboard</h1>
<p>Links:</p>
<ul>
<li>Metric <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/awaiting_prs_by_sig.sql" target="_blank">SQL file</a>.</li>
<li>Metric (repository version) <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/awaiting_prs_by_sig_repos.sql" target="_blank">SQL file</a>.</li>
<li>TSDB <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/metrics.yaml" target="_blank">series definition</a>. Search for <code>awaiting_prs_by_sig</code></li>
<li>TSDB (repository version) <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/metrics.yaml" target="_blank">series definition</a>. Search for <code>awaiting_prs_by_sig_repos</code></li>
<li>Grafana dashboard <a href="https://github.com/cncf/devstats/blob/master/grafana/dashboards/kubernetes/awaiting-prs-by-sig.json" target="_blank">JSON</a>.</li>
<li>Grafana dashboard (repository version) <a href="https://github.com/cncf/devstats/blob/master/grafana/dashboards/kubernetes/awaiting-prs-by-sig-and-repository.json" target="_blank">JSON</a>.</li>
</ul>
<h1 id="description">Description</h1>
<ul>
<li>This dashboard shows the number of PRs opened by SIG that were open for longer than 10, 30, 60, 90 days and 1 year.</li>
<li>We're counting PRs that were opened more than specified amount of time at given point in time, so for example data for 1 month ago show PRs that were open for more than 10 days 1 month ago (now they may be open for 2 months or merged already).</li>
<li>PR belongs to SIG by using <code>sig/*</code> labels. List of SIGs to display in drop-down comes from all <code>sig/*</code> labels.</li>
<li>You can select repository to see single repository statistics (repositories version).</li>
</ul>
