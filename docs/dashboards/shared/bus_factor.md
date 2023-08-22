<h1 id="dashboard-header">[[full_name]] Elephant/Bus factor in Repository Groups dashboard</h1>
<p>Links:</p>
<ul>
<li>Metric <a href="https://github.com/cncf/devstats/blob/master/metrics/shared/bus_factor.sql" target="_blank">SQL file</a>.</li>
<li>TSDB <a href="https://github.com/cncf/devstats/blob/master/metrics/all/metrics.yaml" target="_blank">series definition</a>. Search for <code>bus_factor</code></li>
<li>Grafana dashboard <a href="https://github.com/cncf/devstats/blob/master/grafana/dashboards/[[lower_name]]/elephant-bus-factor-in-repository-groups.json" target="_blank">JSON</a>.</li>
</ul>
<h1 id="description">Description</h1>
<ul>
<li>This dashboard show elephant/bus factor and top 10 companies/contributors data for a given repository group and metric combination.</li>
<li>You can choose between organizations/companies and users/contributors elephant/bus factor/top 10 stats.</li>
<li>Bus factor value for a selected repository group/project is a minimal number of companies/contributors that contribute to >50% of all contributions of given type.</li>
<li>When calculating for companies, we name it "elephant" factor, while for contributors we name it "bus" factor.</li>
<li>It also displays companies/users who contribute to a bus factor and top 10 and percentage value of those contributions plus percentage and counts of the remaining contributors/organizations.</li>
<li>You can select last day, month, week etc. range or date range between releases, for example <code>v1.9 - v1.10</code>.</li>
<li>See <a href="https://github.com/cncf/devstats/blob/master/docs/periods.md" target="_blank">here</a> for more informations about periods.</li>
<li>We are skipping bots activity, see <a href="https://github.com/cncf/devstats/blob/master/docs/excluding_bots.md" target="_blank">excluding bots</a> for details.</li>
<li><code>Project/Repository Group</code>: CNCF project name (in case of All CNCF DevStats instance).</li>
<li><code>BF</code>: Bus Factor value - the smallest number of users/organizations who contribute over 50% of a given metric type in a selected time range.</li>
<li><code>BF %</code>: Percent value of contributions for bus factor number of top organizations/users.</li>
<li><code>Bus Factor</code>: List of organizations/users which belong to the calculated bus factor.</li>
<li>This is truncated at 10, so if the bus factor is > 10 then only 1st 10 will show (otherwise cell value will be too long, as is quite rare to have a bus factor > 10, so not a big limitation, and I can eventually change it if needed).</li>
<li><code>Oth. #</code>: Count of the remaining users/organizations (those not in the bus factor, the remaining tail length).</li>
<li><code>Oth. %</code>: Percent of remaining contributions.</li>
<li><code>Top 10 %</code>: How many percent contributions are coming from the top 10 organizations/users (if this is 100% then it can be from less than 10 - it can happen that only 4 organizations contribute to a project in a given time period for example).</li>
<li><code>Top</code>: Top 10 companies/users listed (there can be less than 10).</li>
<li><code>Rem. #</code>: Count of the remaining companies/users outside of top 10 (can be 0).</li>
<li><code>Rem. %</code>: Percent of contributions from companies/users outside of top 10.</li>
</ul>
