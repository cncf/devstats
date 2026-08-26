<p style="background-color:#4a3200;border:1px solid orange;color:#ffd;padding:8px;">&#9888;&#65039; <b>Data accuracy warning:</b> DevStats uses the public <a href="https://www.gharchive.org" target="_blank">GH Archive</a> dataset, which is missing a significant number of GitHub events (notably in recent months), so contributions data shown here is undercounted. Please do not treat those numbers as 100% accurate or complete, see <a href="https://github.com/cncf/devstats/issues/147" target="_blank">cncf/devstats#147</a> for details.</p>
<h1 id="kubernetes-dashboard">[[full_name]] Inactive PRs by SIG (and repository) dashboard</h1>
<p>Links:</p>
<ul>
<li>Metric <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/inactive_prs_by_sig.sql" target="_blank">SQL file</a>.</li>
<li>Metric (repositories version) <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/inactive_prs_by_sig_repos.sql" target="_blank">SQL file</a>.</li>
<li>TSDB <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/metrics.yaml" target="_blank">series definition</a>. Search for <code>inactive_prs_by_sig</code></li>
<li>TSDB (repositories version) <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/metrics.yaml" target="_blank">series definition</a>. Search for <code>inactive_prs_by_sig_repos</code></li>
<li>Grafana dashboard <a href="https://github.com/cncf/devstats/blob/master/grafana/dashboards/kubernetes/inactive-prs-by-sig.json" target="_blank">JSON</a>.</li>
<li>Grafana dashboard (repositories) <a href="https://github.com/cncf/devstats/blob/master/grafana/dashboards/kubernetes/inactive-prs-by-sig-and-repository.json" target="_blank">JSON</a>.</li>
</ul>
<h1 id="description">Description</h1>
<ul>
<li>This dashboard shows the number of PRs opened by SIG that were inactive for longer than 14, 30 and 90 days.</li>
<li>Inactive means PRs that are open and have no activity other than author and bots more than specified amount of time at given point in time, so for example data for 2 weeks ago show PRs that were inactive for more than 14 days 2 weeks ago (now they may be inactive for 1 month or some activity happened earlier than 14 days ago).</li>
<li>PR belongs to SIG by using <code>sig/*</code> labels. List of SIGs to display in drop-down comes from all <code>sig/*</code> labels.</li>
<li>In repositories version you can select repository to per single repository statistics. Note that not all SIGs may be present in may repos, so you need to select a sub-set or a single one from SIG drop down.</li>
</ul>
