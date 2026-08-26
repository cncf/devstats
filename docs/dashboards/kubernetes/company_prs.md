<p style="background-color:#4a3200;border:1px solid orange;color:#ffd;padding:8px;">&#9888;&#65039; <b>Data accuracy warning:</b> DevStats uses the public <a href="https://www.gharchive.org" target="_blank">GH Archive</a> dataset, which is missing a significant number of GitHub events (notably in recent months), so contributions data shown here is undercounted. Please do not treat those numbers as 100% accurate or complete, see <a href="https://github.com/cncf/devstats/issues/147" target="_blank">cncf/devstats#147</a> for details.</p>
<h1 id="dashboard-header">[[full_name]] company PRs in repository groups dashboard</h1>
<p>Links:</p>
<ul>
<li>Metric (repository groups) <a href="https://github.com/cncf/devstats/blob/master/metrics/shared/company_prs.sql" target="_blank">SQL file</a>.</li>
<li>Metric (repositories) <a href="https://github.com/cncf/devstats/blob/master/metrics/shared/company_prs_repos.sql" target="_blank">SQL file</a>.</li>
<li>TSDB <a href="https://github.com/cncf/devstats/blob/master/metrics/shared/metrics.yaml" target="_blank">series definition</a>. Search for <code>company_prs</code></li>
<li>Grafana dashboard <a href="https://github.com/cncf/devstats/blob/master/grafana/dashboards/[[lower_name]]/company-prs-in-repository-groups.json" target="_blank">JSON</a>.</li>
</ul>
<h1 id="description">Description</h1>
<ul>
<li>This dashboard shows how many PRs were open by given company's developer in given repository groups</li>
<li>You can select one, two or more companies or All to select all of them.</li>
<li>You can select one, two or more repository groups or All to select all fo them (for the top panel).</li>
<li>You can select repositories for the bottom panel showing separate repositories statistics.</li>
<li>You can select last day, month, week etc. range or date range between releases, for example <code>v1.9 - v1.10</code>.</li>
<li>See <a href="https://github.com/cncf/devstats/blob/master/docs/periods.md" target="_blank">here</a> for more informations about periods.</li>
<li>See <a href="https://github.com/cncf/devstats/blob/master/docs/repository_groups.md" target="_blank">here</a> for more informations about repository groups.</li>
<li>We are determining user's company affiliation from <a href="https://github.com/cncf/devstats/blob/master/github_users.json" target="_blank">this file</a>, which is imported from <code>cncf/gitdm</code>.</li>
</ul>
