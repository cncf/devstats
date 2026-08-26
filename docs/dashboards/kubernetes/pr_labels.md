<p style="background-color:#4a3200;border:1px solid orange;color:#ffd;padding:8px;">&#9888;&#65039; <b>Data accuracy warning:</b> DevStats uses the public <a href="https://www.gharchive.org" target="_blank">GH Archive</a> dataset, which is missing a significant number of GitHub events (notably in recent months), so contributions data shown here is undercounted. Please do not treat those numbers as 100% accurate or complete, see <a href="https://github.com/cncf/devstats/issues/147" target="_blank">cncf/devstats#147</a> for details.</p>
<h1 id="kubernetes-dashboard">[[full_name]] PR labels repository/repository groups dashboard</h1>
<p>Links:</p>
<ul>
<li>Metric (repo groups) <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/prs_labels.sql" target="_blank">SQL file</a>.</li>
<li>Metric (repositories) <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/prs_labels_repos.sql" target="_blank">SQL file</a>.</li>
<li>TSDB <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/metrics.yaml" target="_blank">series definition</a>. Search for <code>prs_labels</code></li>
<li>Grafana dashboard (repo groups) <a href="https://github.com/cncf/devstats/blob/master/grafana/dashboards/kubernetes/prs-labels-repository-groups.json" target="_blank">JSON</a>.</li>
<li>Grafana dashboard (repositories) <a href="https://github.com/cncf/devstats/blob/master/grafana/dashboards/kubernetes/prs-labels-repositories.json" target="_blank">JSON</a>.</li>
</ul>
<h1 id="description">Description</h1>
<ul>
<li>This dashboard how many PRs have/had a specified label(s) in a given repository/repository group(s) at given point in time.</li>
<li>List of labels is hardcoded. It contains PR merge blocker labels.</li>
<li>You can select any of labels from given set or choose <code>All labels combined</code>.</li>
<li>You can select single repository group or summary for all of them <code>All repos combined</code>.</li>
<li>You can select single repository for repositories version.</li>
<li>There are multiple charts that show summaries for all repo groups and/or for all labels.</li>
<li>See <a href="https://github.com/cncf/devstats/blob/master/docs/repository_groups.md" target="_blank">here</a> for more informations about repository groups.</li>
</ul>
