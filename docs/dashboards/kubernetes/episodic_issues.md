<p style="background-color:#4a3200;border:1px solid orange;color:#ffd;padding:8px;">&#9888;&#65039; <b>Data accuracy warning:</b> DevStats uses the public <a href="https://www.gharchive.org" target="_blank">GH Archive</a> dataset, which is missing a significant number of GitHub events (notably in recent months), so contributions data shown here is undercounted. Please do not treat those numbers as 100% accurate or complete, see <a href="https://github.com/cncf/devstats/issues/147" target="_blank">cncf/devstats#147</a> for details.</p>
<h1 id="kubernetes-dashboard">[[full_name]] New And Episodic Issue Creators dashboard</h1>
<p>Links:</p>
<ul>
<li>New issues metric (repo groups) <a href="https://github.com/cncf/devstats/blob/master/metrics/shared/new_issues.sql" target="_blank">SQL file</a>.</li>
<li>Episodic issues metric (repo groups) <a href="https://github.com/cncf/devstats/blob/master/metrics/shared/episodic_issues.sql" target="_blank">SQL file</a>.</li>
<li>New issues metric (repos) <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/new_issues_repos.sql" target="_blank">SQL file</a>.</li>
<li>Episodic issues metric (repos) <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/episodic_issues_repos.sql" target="_blank">SQL file</a>.</li>
<li>TSDB <a href="https://github.com/cncf/devstats/blob/master/metrics/kubernetes/metrics.yaml" target="_blank">series definition</a>. Search for <code>New and episodic issue</code></li>
<li>Grafana dashboard <a href="https://github.com/cncf/devstats/blob/master/grafana/dashboards/kubernetes/new-and-episodic-issue-creators.json" target="_blank">JSON</a>.</li>
</ul>
<h1 id="description">Description</h1>
<ul>
<li>This dashboard shows statistics about new and episodic issues and issue creators.</li>
<li>New issue creator is someone who haven't created any issue before given period.</li>
<li>New issue is an issue created by new issue creator</li>
<li>Episodic issue creator is someone who haven't created any issue in 3 months before given project and haven't created more than 12 issues overall.</li>
<li>Episodic issue is an issue created by episodic issue creator.</li>
<li>You can select single repository group or summary for all of them (for the top panel).</li>
<li>You can select repository for bottom panel showing per single repository statistics.</li>
<li>Selecting period (for example week) means that dashboard will calculate statistics in those periods.</li>
<li>See <a href="https://github.com/cncf/devstats/blob/master/docs/periods.md" target="_blank">here</a> for more informations about periods.</li>
<li>See <a href="https://github.com/cncf/devstats/blob/master/docs/repository_groups.md" target="_blank">here</a> for more informations about repository groups.</li>
</ul>
