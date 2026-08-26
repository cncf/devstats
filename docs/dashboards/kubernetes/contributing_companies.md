<p style="background-color:#4a3200;border:1px solid orange;color:#ffd;padding:8px;">&#9888;&#65039; <b>Data accuracy warning:</b> DevStats uses the public <a href="https://www.gharchive.org" target="_blank">GH Archive</a> dataset, which is missing a significant number of GitHub events (notably in recent months), so contributions data shown here is undercounted. Please do not treat those numbers as 100% accurate or complete, see <a href="https://github.com/cncf/devstats/issues/147" target="_blank">cncf/devstats#147</a> for details.</p>
<h1 id="kubernetes-dashboard">[[full_name]] Companies contributing in repository groups dashboard</h1>
<p>Links:</p>
<ul>
<li>Metric (repo groups) <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/num_stats.sql" target="_blank">SQL file</a>.</li>
<li>Metric (repositories) <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/num_stats_repos.sql" target="_blank">SQL file</a>.</li>
<li>TSDB <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/metrics.yaml" target="_blank">series definition</a>. Search for <code>num_stats</code></li>
<li>Grafana dashboard <a href="https://github.com/cncf/devstats/blob/master/grafana/dashboards/kubernetes/companies-contributing-in-repository-groups.json" target="_blank">JSON</a>.</li>
</ul>
<h1 id="description">Description</h1>
<ul>
<li>This dashboard shows how many companies and developers are contributing in a given repository group.</li>
<li>By contributor we mean someone who made a review, comment, commit, created issue or PR, reviwed PR, commented on issue or PR.</li>
<li>You can select single repository group or summary for all of them (for the top panel showing repository groups).</li>
<li>You can select repository for the bottom panel showing per single repository statistics.</li>
<li>Selecting period (for example week) means that dashboard will show data in those periods.</li>
<li>See <a href="https://github.com/cncf/devstats/blob/master/docs/periods.md" target="_blank">here</a> for more informations about periods.</li>
<li>See <a href="https://github.com/cncf/devstats/blob/master/docs/repository_groups.md" target="_blank">here</a> for more informations about repository groups.</li>
<li>We are skipping bots activity, see <a href="https://github.com/cncf/devstats/blob/master/docs/excluding_bots.md" target="_blank">excluding bots</a> for details.</li>
<li>We are determining user's company affiliation from <a href="https://github.com/cncf/devstats/blob/master/github_users.json" target="_blank">this file</a>, which is imported from <code>cncf/gitdm</code>.</li>
</ul>
