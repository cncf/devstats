-- k exec -in devstats-prod devstats-postgres-0 -c devstats-postgres -- psql --csv istio < util_sql/istio_developers_report_only_istio_org.sql > ~/istio_developers_report_only_istio_org.csv

create temp table hdev_repo_groups_ea0c838752e54bd2 as
select
  id,
  name,
  repo_group
from
  gha_repo_groups
where
  repo_group in (select repo_group_name from trepo_groups)
  and org_login = 'istio' 
;
create index on hdev_repo_groups_ea0c838752e54bd2 (id, name);
analyze hdev_repo_groups_ea0c838752e54bd2;

create temp table hdev_commits_data_ea0c838752e54bd2 as
select
  r.repo_group,
  c.sha,
  v.actor_id as actor_id,
  lower(v.actor_login) as actor_login,
  coalesce(aa.company_name, '') as company
from
  hdev_repo_groups_ea0c838752e54bd2 r
join
  gha_commits c
on
  c.dup_repo_id = r.id
  and c.dup_repo_name = r.name
cross join lateral
  (values
    ('actor', c.dup_actor_id, c.dup_actor_login),
    ('author', c.author_id, c.dup_author_login),
    ('committer', c.committer_id, c.dup_committer_login)
  ) v(role, actor_id, actor_login)
left join
  gha_actors_affiliations aa
on
  aa.actor_id = v.actor_id
  and aa.dt_from <= c.dup_created_at
  and aa.dt_to > c.dup_created_at
where
   (c.dup_created_at >= '2025-02-01 00:00:00' and c.dup_created_at < '2026-02-01 00:00:00') 
  and (v.role = 'actor' or v.actor_id is not null)
  and (lower(v.actor_login) not like all(array['copilot', 'claude', 'codex', 'openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci'])
)
union all
select
  r.repo_group,
  cr.sha,
  cr.actor_id as actor_id,
  lower(cr.actor_login) as actor_login,
  coalesce(aa.company_name, '') as company
from
  hdev_repo_groups_ea0c838752e54bd2 r
join
  gha_commits_roles cr
on
  cr.dup_repo_id = r.id
  and cr.dup_repo_name = r.name
left join
  gha_actors_affiliations aa
on
  aa.actor_id = cr.actor_id
  and aa.dt_from <= cr.dup_created_at
  and aa.dt_to > cr.dup_created_at
where
  cr.actor_id is not null
  and cr.actor_id <> 0
  and cr.role = 'Co-authored-by'
  and  (cr.dup_created_at >= '2025-02-01 00:00:00' and cr.dup_created_at < '2026-02-01 00:00:00') 
  and (lower(cr.actor_login) not like all(array['copilot', 'claude', 'codex', 'openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci'])
)
;
create index on hdev_commits_data_ea0c838752e54bd2 (repo_group);
create index on hdev_commits_data_ea0c838752e54bd2 (actor_id);
analyze hdev_commits_data_ea0c838752e54bd2;

create temp table hdev_events_ea0c838752e54bd2 as
select
  e.id,
  e.type,
  e.repo_id,
  rg.repo_group,
  e.actor_id,
  e.dup_actor_login,
  lower(e.dup_actor_login) as dup_actor_login_lower,
  aa.company_name as company_name
from
  gha_events e
join
  gha_orgs o
on
  o.id = e.org_id
  and o.login = 'istio'
left join
  hdev_repo_groups_ea0c838752e54bd2 rg
on
  rg.id = e.repo_id
  and rg.name = e.dup_repo_name
left join
  gha_actors_affiliations aa
on
  aa.actor_id = e.actor_id
  and aa.dt_from <= e.created_at
  and aa.dt_to > e.created_at
where
   (e.created_at >= '2025-02-01 00:00:00' and e.created_at < '2026-02-01 00:00:00') 
;
create index on hdev_events_ea0c838752e54bd2 (actor_id);
create index on hdev_events_ea0c838752e54bd2 (dup_actor_login);
create index on hdev_events_ea0c838752e54bd2 (repo_group);
create index on hdev_events_ea0c838752e54bd2 (type);
analyze hdev_events_ea0c838752e54bd2;

create temp table hdev_comments_ea0c838752e54bd2 as
select
  c.id,
  rg.repo_group,
  c.user_id as actor_id,
  c.dup_user_login,
  lower(c.dup_user_login) as dup_user_login_lower,
  aa.company_name as company_name
from
  gha_comments c
join
  hdev_repo_groups_ea0c838752e54bd2 rg
on
  rg.id = c.dup_repo_id
  and rg.name = c.dup_repo_name
left join
  gha_actors_affiliations aa
on
  aa.actor_id = c.user_id
  and aa.dt_from <= c.created_at
  and aa.dt_to > c.created_at
where
   (c.created_at >= '2025-02-01 00:00:00' and c.created_at < '2026-02-01 00:00:00') 
;
create index on hdev_comments_ea0c838752e54bd2 (actor_id);
create index on hdev_comments_ea0c838752e54bd2 (dup_user_login);
create index on hdev_comments_ea0c838752e54bd2 (repo_group);
analyze hdev_comments_ea0c838752e54bd2;

create temp table hdev_issues_ea0c838752e54bd2 as
select
  i.id,
  rg.repo_group,
  i.is_pull_request,
  i.user_id as actor_id,
  i.dup_user_login,
  lower(i.dup_user_login) as dup_user_login_lower,
  aa.company_name as company_name
from
  gha_issues i
join
  hdev_repo_groups_ea0c838752e54bd2 rg
on
  rg.id = i.dup_repo_id
  and rg.name = i.dup_repo_name
left join
  gha_actors_affiliations aa
on
  aa.actor_id = i.user_id
  and aa.dt_from <= i.created_at
  and aa.dt_to > i.created_at
where
   (i.created_at >= '2025-02-01 00:00:00' and i.created_at < '2026-02-01 00:00:00') 
;
create index on hdev_issues_ea0c838752e54bd2 (actor_id);
create index on hdev_issues_ea0c838752e54bd2 (dup_user_login);
create index on hdev_issues_ea0c838752e54bd2 (repo_group);
create index on hdev_issues_ea0c838752e54bd2 (is_pull_request);
analyze hdev_issues_ea0c838752e54bd2;

create temp table hdev_merged_prs_ea0c838752e54bd2 as
select
  pr.id,
  rg.repo_group,
  pr.user_id as actor_id,
  pr.dup_user_login,
  lower(pr.dup_user_login) as dup_user_login_lower,
  aa.company_name as company_name
from
  gha_pull_requests pr
join
  hdev_repo_groups_ea0c838752e54bd2 rg
on
  rg.id = pr.dup_repo_id
  and rg.name = pr.dup_repo_name
left join
  gha_actors_affiliations aa
on
  aa.actor_id = pr.user_id
  and aa.dt_from <= pr.merged_at
  and aa.dt_to > pr.merged_at
where
  pr.merged_at is not null
  and  (pr.merged_at >= '2025-02-01 00:00:00' and pr.merged_at < '2026-02-01 00:00:00') 
;
create index on hdev_merged_prs_ea0c838752e54bd2 (actor_id);
create index on hdev_merged_prs_ea0c838752e54bd2 (dup_user_login);
create index on hdev_merged_prs_ea0c838752e54bd2 (repo_group);
analyze hdev_merged_prs_ea0c838752e54bd2;

create temp table hdev_actors_country_ea0c838752e54bd2 as
select
  id,
  login,
  lower(login) as login_lower,
  country_name
from
  gha_actors
where
  country_name is not null
;
create index on hdev_actors_country_ea0c838752e54bd2 (id);
create index on hdev_actors_country_ea0c838752e54bd2 (login);
analyze hdev_actors_country_ea0c838752e54bd2;

create temp table hdev_events_country_ea0c838752e54bd2 as
select
  e.id,
  e.repo_id,
  e.repo_group,
  e.type,
  e.dup_actor_login_lower as src_login_lower,
  a.country_name as country,
  a.login_lower as author,
  e.company_name as company_name
from
  hdev_events_ea0c838752e54bd2 e
join
  hdev_actors_country_ea0c838752e54bd2 a
on
  a.id = e.actor_id
union all
select
  e.id,
  e.repo_id,
  e.repo_group,
  e.type,
  e.dup_actor_login_lower as src_login_lower,
  a.country_name as country,
  a.login_lower as author,
  e.company_name as company_name
from
  hdev_events_ea0c838752e54bd2 e
join
  hdev_actors_country_ea0c838752e54bd2 a
on
  a.login = e.dup_actor_login
where
  e.actor_id is null
  or a.id <> e.actor_id
;
create index on hdev_events_country_ea0c838752e54bd2 (repo_group);
create index on hdev_events_country_ea0c838752e54bd2 (country);
analyze hdev_events_country_ea0c838752e54bd2;

create temp table hdev_comments_country_ea0c838752e54bd2 as
select
  c.id,
  c.repo_group,
  c.dup_user_login_lower as src_login_lower,
  a.country_name as country,
  a.login_lower as author,
  c.company_name as company_name
from
  hdev_comments_ea0c838752e54bd2 c
join
  hdev_actors_country_ea0c838752e54bd2 a
on
  a.id = c.actor_id
union all
select
  c.id,
  c.repo_group,
  c.dup_user_login_lower as src_login_lower,
  a.country_name as country,
  a.login_lower as author,
  c.company_name as company_name
from
  hdev_comments_ea0c838752e54bd2 c
join
  hdev_actors_country_ea0c838752e54bd2 a
on
  a.login = c.dup_user_login
where
  c.actor_id is null
  or a.id <> c.actor_id
;
create index on hdev_comments_country_ea0c838752e54bd2 (repo_group);
create index on hdev_comments_country_ea0c838752e54bd2 (country);
analyze hdev_comments_country_ea0c838752e54bd2;

create temp table hdev_issues_country_ea0c838752e54bd2 as
select
  i.id,
  i.repo_group,
  i.is_pull_request,
  i.dup_user_login_lower as src_login_lower,
  a.country_name as country,
  a.login_lower as author,
  i.company_name as company_name
from
  hdev_issues_ea0c838752e54bd2 i
join
  hdev_actors_country_ea0c838752e54bd2 a
on
  a.id = i.actor_id
union all
select
  i.id,
  i.repo_group,
  i.is_pull_request,
  i.dup_user_login_lower as src_login_lower,
  a.country_name as country,
  a.login_lower as author,
  i.company_name as company_name
from
  hdev_issues_ea0c838752e54bd2 i
join
  hdev_actors_country_ea0c838752e54bd2 a
on
  a.login = i.dup_user_login
where
  i.actor_id is null
  or a.id <> i.actor_id
;
create index on hdev_issues_country_ea0c838752e54bd2 (repo_group);
create index on hdev_issues_country_ea0c838752e54bd2 (country);
analyze hdev_issues_country_ea0c838752e54bd2;

create temp table hdev_merged_prs_country_ea0c838752e54bd2 as
select
  pr.id,
  pr.repo_group,
  pr.dup_user_login_lower as src_login_lower,
  a.country_name as country,
  a.login_lower as author,
  pr.company_name as company_name
from
  hdev_merged_prs_ea0c838752e54bd2 pr
join
  hdev_actors_country_ea0c838752e54bd2 a
on
  a.id = pr.actor_id
union all
select
  pr.id,
  pr.repo_group,
  pr.dup_user_login_lower as src_login_lower,
  a.country_name as country,
  a.login_lower as author,
  pr.company_name as company_name
from
  hdev_merged_prs_ea0c838752e54bd2 pr
join
  hdev_actors_country_ea0c838752e54bd2 a
on
  a.login = pr.dup_user_login
where
  pr.actor_id is null
  or a.id <> pr.actor_id
;
create index on hdev_merged_prs_country_ea0c838752e54bd2 (repo_group);
create index on hdev_merged_prs_country_ea0c838752e54bd2 (country);
analyze hdev_merged_prs_country_ea0c838752e54bd2;

with
events_type_all as (
  select
    case type
      when 'PushEvent' then 'pushes'
      when 'PullRequestReviewCommentEvent' then 'review_comments'
      when 'PullRequestReviewEvent' then 'reviews'
      when 'IssueCommentEvent' then 'issue_comments'
      when 'CommitCommentEvent' then 'commit_comments'
    end as metric,
    dup_actor_login_lower as author,
    coalesce(company_name, '') as company,
    count(id) as value
  from
    hdev_events_ea0c838752e54bd2
  where
    type in (
      'PushEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent',
      'IssueCommentEvent', 'CommitCommentEvent'
    )
    and (dup_actor_login_lower not like all(array['copilot', 'claude', 'codex', 'openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci'])
)
  group by
    type,
    dup_actor_login_lower,
    company_name
), events_overall_all as (
  select
    dup_actor_login_lower as author,
    company_name,
    count(id) as events_value,
    count(distinct repo_id) as active_repos_value,
    count(distinct id) filter (
      where type in (
        'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
        'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
      )
    ) as contributions_value
  from
    hdev_events_ea0c838752e54bd2
  where
    (dup_actor_login_lower not like all(array['copilot', 'claude', 'codex', 'openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci'])
)
  group by
    dup_actor_login_lower,
    company_name
), all_all_sub as (
  select
    'commits' as metric,
    actor_login as author,
    company as company,
    count(distinct sha) as value
  from
    hdev_commits_data_ea0c838752e54bd2
  group by
    actor_login,
    company
  union all
  select
    metric,
    author,
    company,
    value
  from
    events_type_all
  union all
  select
    'contributions' as metric,
    author,
    coalesce(company_name, '') as company,
    contributions_value as value
  from
    events_overall_all
  union all
  select
    'active_repos' as metric,
    author,
    coalesce(company_name, '') as company,
    active_repos_value as value
  from
    events_overall_all
  union all
  select
    'events' as metric,
    author,
    coalesce(company_name, '') as company,
    events_value as value
  from
    events_overall_all
  union all
  select
    'comments' as metric,
    dup_user_login_lower as author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_comments_ea0c838752e54bd2
  where
    (dup_user_login_lower not like all(array['copilot', 'claude', 'codex', 'openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci'])
)
  group by
    dup_user_login_lower,
    company_name
  union all
  select
    case is_pull_request when true then 'prs' else 'issues' end as metric,
    dup_user_login_lower as author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_issues_ea0c838752e54bd2
  where
    (dup_user_login_lower not like all(array['copilot', 'claude', 'codex', 'openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci'])
)
  group by
    is_pull_request,
    dup_user_login_lower,
    company_name
  union all
  select
    'merged_prs' as metric,
    dup_user_login_lower as author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_merged_prs_ea0c838752e54bd2
  where
    (dup_user_login_lower not like all(array['copilot', 'claude', 'codex', 'openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci'])
)
  group by
    dup_user_login_lower,
    company_name
), all_all as (
  select
    metric,
    author,
    company,
    value
  from
    all_all_sub
--   where
--     (metric = 'events' and value > 100 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric = 'active_repos' and value > 3 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric = 'contributions' and value > 10 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric = 'commit_comments' and value > 3 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric = 'comments' and value > 20 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric = 'reviews' and value > 15 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric = 'issue_comments' and value > 20 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric = 'review_comments' and value > 20 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric in ('commits','pushes','issues','prs','merged_prs') and value > 0.8 * 1.0 * sqrt(24.000000/1450.0))
), events_type_rg as (
  select
    case type
      when 'PushEvent' then 'pushes'
      when 'PullRequestReviewCommentEvent' then 'review_comments'
      when 'PullRequestReviewEvent' then 'reviews'
      when 'IssueCommentEvent' then 'issue_comments'
      when 'CommitCommentEvent' then 'commit_comments'
    end as metric,
    repo_group,
    dup_actor_login_lower as author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_events_ea0c838752e54bd2
  where
    repo_group is not null
    and type in (
      'PushEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent',
      'IssueCommentEvent', 'CommitCommentEvent'
    )
    and (dup_actor_login_lower not like all(array['copilot', 'claude', 'codex', 'openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci'])
)
  group by
    type,
    repo_group,
    dup_actor_login_lower,
    coalesce(company_name, '')
), events_overall_rg as (
  select
    repo_group,
    dup_actor_login_lower as author,
    coalesce(company_name, '') as company,
    count(distinct id) as events_value,
    count(distinct repo_id) as active_repos_value,
    count(distinct id) filter (
      where type in (
        'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
        'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
      )
    ) as contributions_value
  from
    hdev_events_ea0c838752e54bd2
  where
    repo_group is not null
    and (dup_actor_login_lower not like all(array['copilot', 'claude', 'codex', 'openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci'])
)
  group by
    repo_group,
    dup_actor_login_lower,
    coalesce(company_name, '')
), rg_all_sub as (
  select
    'commits' as metric,
    repo_group,
    actor_login as author,
    company as company,
    count(distinct sha) as value
  from
    hdev_commits_data_ea0c838752e54bd2
  where
    repo_group is not null
  group by
    repo_group,
    actor_login,
    company
  union all
  select
    metric,
    repo_group,
    author,
    company,
    value
  from
    events_type_rg
  union all
  select
    'contributions' as metric,
    repo_group,
    author,
    company,
    contributions_value as value
  from
    events_overall_rg
  union all
  select
    'active_repos' as metric,
    repo_group,
    author,
    company,
    active_repos_value as value
  from
    events_overall_rg
  union all
  select
    'events' as metric,
    repo_group,
    author,
    company,
    events_value as value
  from
    events_overall_rg
  union all
  select
    'comments' as metric,
    repo_group,
    dup_user_login_lower as author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_comments_ea0c838752e54bd2
  where
    repo_group is not null
    and (dup_user_login_lower not like all(array['copilot', 'claude', 'codex', 'openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci'])
)
  group by
    repo_group,
    dup_user_login_lower,
    coalesce(company_name, '')
  union all
  select
    case is_pull_request when true then 'prs' else 'issues' end as metric,
    repo_group,
    dup_user_login_lower as author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_issues_ea0c838752e54bd2
  where
    repo_group is not null
    and (dup_user_login_lower not like all(array['copilot', 'claude', 'codex', 'openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci'])
)
  group by
    repo_group,
    is_pull_request,
    dup_user_login_lower,
    coalesce(company_name, '')
  union all
  select
    'merged_prs' as metric,
    repo_group,
    dup_user_login_lower as author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_merged_prs_ea0c838752e54bd2
  where
    repo_group is not null
    and (dup_user_login_lower not like all(array['copilot', 'claude', 'codex', 'openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci'])
)
  group by
    repo_group,
    dup_user_login_lower,
    coalesce(company_name, '')
), rg_all as (
  select
    metric,
    repo_group,
    author,
    company,
    value
  from
    rg_all_sub
--   where
--     (metric = 'events' and value > 80 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric = 'active_repos' and value > 3 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric = 'contributions' and value > 5 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric = 'commit_comments' and value > 2 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric = 'comments' and value > 10 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric = 'reviews' and value > 5 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric = 'issue_comments' and value > 10 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric = 'review_comments' and value > 10 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric in ('commits','pushes','issues','prs','merged_prs') and value > 0.5 * 1.0 * sqrt(24.000000/1450.0))
), events_type_country_all as (
  select
    case type
      when 'PushEvent' then 'pushes'
      when 'PullRequestReviewCommentEvent' then 'review_comments'
      when 'PullRequestReviewEvent' then 'reviews'
      when 'IssueCommentEvent' then 'issue_comments'
      when 'CommitCommentEvent' then 'commit_comments'
    end as metric,
    country,
    author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_events_country_ea0c838752e54bd2
  where
    type in (
      'PushEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent',
      'IssueCommentEvent', 'CommitCommentEvent'
    )
    and (author not like all(array['copilot', 'claude', 'codex', 'openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci'])
)
  group by
    type,
    country,
    author,
    company_name
), events_overall_country_all as (
  select
    country,
    author,
    company_name,
    count(distinct id) as events_value,
    count(distinct repo_id) as active_repos_value,
    count(distinct id) filter (
      where type in (
        'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
        'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
      )
    ) as contributions_value
  from
    hdev_events_country_ea0c838752e54bd2
  where
    (author not like all(array['copilot', 'claude', 'codex', 'openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci'])
)
  group by
    country,
    author,
    company_name
), country_all_sub as (
  select
    'commits' as metric,
    a.country_name as country,
    a.login as author,
    c.company as company,
    count(distinct c.sha) as value
  from
    hdev_commits_data_ea0c838752e54bd2 c
  join
    hdev_actors_country_ea0c838752e54bd2 a
  on
    a.id = c.actor_id
  group by
    a.country_name,
    a.login,
    c.company
  union all
  select
    metric,
    country,
    author,
    company,
    value
  from
    events_type_country_all
  union all
  select
    'contributions' as metric,
    country,
    author,
    coalesce(company_name, '') as company,
    contributions_value as value
  from
    events_overall_country_all
  union all
  select
    'active_repos' as metric,
    country,
    author,
    coalesce(company_name, '') as company,
    active_repos_value as value
  from
    events_overall_country_all
  union all
  select
    'events' as metric,
    country,
    author,
    coalesce(company_name, '') as company,
    events_value as value
  from
    events_overall_country_all
  union all
  select
    'comments' as metric,
    country,
    author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_comments_country_ea0c838752e54bd2
  where
    (author not like all(array['copilot', 'claude', 'codex', 'openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci'])
)
  group by
    country,
    author,
    company_name
  union all
  select
    case is_pull_request when true then 'prs' else 'issues' end as metric,
    country,
    author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_issues_country_ea0c838752e54bd2
  where
    (author not like all(array['copilot', 'claude', 'codex', 'openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci'])
)
  group by
    is_pull_request,
    country,
    author,
    company_name
  union all
  select
    'merged_prs' as metric,
    country,
    author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_merged_prs_country_ea0c838752e54bd2
  where
    (author not like all(array['copilot', 'claude', 'codex', 'openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci'])
)
  group by
    country,
    author,
    company_name
), country_all as (
  select
    metric,
    country,
    author,
    company,
    value
  from
    country_all_sub
--   where
--     (metric = 'events' and value > 100 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric = 'active_repos' and value > 3 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric = 'contributions' and value > 5 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric = 'commit_comments' and value > 2 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric = 'comments' and value > 10 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric = 'reviews' and value > 5 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric = 'issue_comments' and value > 10 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric = 'review_comments' and value > 10 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric in ('commits','pushes','issues','prs','merged_prs') and value > 0.5 * 1.0 * sqrt(24.000000/1450.0))
), events_type_rg_country as (
  select
    case type
      when 'PushEvent' then 'pushes'
      when 'PullRequestReviewCommentEvent' then 'review_comments'
      when 'PullRequestReviewEvent' then 'reviews'
      when 'IssueCommentEvent' then 'issue_comments'
      when 'CommitCommentEvent' then 'commit_comments'
    end as metric,
    repo_group,
    country,
    author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_events_country_ea0c838752e54bd2
  where
    repo_group is not null
    and country is not null
    and type in (
      'PushEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent',
      'IssueCommentEvent', 'CommitCommentEvent'
    )
    and (author not like all(array['copilot', 'claude', 'codex', 'openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci'])
)
  group by
    type,
    repo_group,
    country,
    author,
    coalesce(company_name, '')
), events_overall_rg_country as (
  select
    repo_group,
    country,
    author,
    coalesce(company_name, '') as company,
    count(distinct repo_id) as active_repos_value,
    count(distinct id) filter (
      where type in (
        'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
        'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
      )
    ) as contributions_value
  from
    hdev_events_country_ea0c838752e54bd2
  where
    repo_group is not null
    and country is not null
    and (author not like all(array['copilot', 'claude', 'codex', 'openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci'])
)
  group by
    repo_group,
    country,
    author,
    coalesce(company_name, '')
), events_rg_country_events_metric as (
  select
    repo_group,
    country,
    author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_events_country_ea0c838752e54bd2
  where
    repo_group is not null
    and country is not null
    and (src_login_lower not like all(array['copilot', 'claude', 'codex', 'openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci'])
)
  group by
    repo_group,
    country,
    author,
    coalesce(company_name, '')
), rg_country_sub as (
  select
    'commits' as metric,
    c.repo_group,
    a.country_name as country,
    a.login as author,
    c.company as company,
    count(distinct c.sha) as value
  from
    hdev_commits_data_ea0c838752e54bd2 c
  join
    hdev_actors_country_ea0c838752e54bd2 a
  on
    a.id = c.actor_id
  where
    c.repo_group is not null
  group by
    c.repo_group,
    a.country_name,
    a.login,
    c.company
  union all
  select
    metric,
    repo_group,
    country,
    author,
    company,
    value
  from
    events_type_rg_country
  union all
  select
    'contributions' as metric,
    repo_group,
    country,
    author,
    company,
    contributions_value as value
  from
    events_overall_rg_country
  union all
  select
    'active_repos' as metric,
    repo_group,
    country,
    author,
    company,
    active_repos_value as value
  from
    events_overall_rg_country
  union all
  select
    'events' as metric,
    repo_group,
    country,
    author,
    company,
    value
  from
    events_rg_country_events_metric
  union all
  select
    'comments' as metric,
    repo_group,
    country,
    author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_comments_country_ea0c838752e54bd2
  where
    repo_group is not null
    and country is not null
    and (author not like all(array['copilot', 'claude', 'codex', 'openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci'])
)
  group by
    repo_group,
    country,
    author,
    coalesce(company_name, '')
  union all
  select
    case is_pull_request when true then 'prs' else 'issues' end as metric,
    repo_group,
    country,
    author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_issues_country_ea0c838752e54bd2
  where
    repo_group is not null
    and country is not null
    and (author not like all(array['copilot', 'claude', 'codex', 'openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci'])
)
  group by
    repo_group,
    is_pull_request,
    country,
    author,
    coalesce(company_name, '')
  union all
  select
    'merged_prs' as metric,
    repo_group,
    country,
    author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_merged_prs_country_ea0c838752e54bd2
  where
    repo_group is not null
    and country is not null
    and (author not like all(array['copilot', 'claude', 'codex', 'openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci'])
)
  group by
    repo_group,
    country,
    author,
    coalesce(company_name, '')
), rg_country as (
  select
    metric,
    repo_group,
    country,
    author,
    company,
    value
  from
    rg_country_sub
--   where
--     (metric = 'events' and value > 20 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric = 'active_repos' and value > 0.5 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric = 'commit_comments' and value > 0.5 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric = 'comments' and value > 2 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric = 'issue_comments' and value > 2 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric = 'review_comments' and value > 2 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric = 'reviews' and value > 2 * 1.0 * sqrt(24.000000/1450.0))
--     or (metric in ('contributions','commits','pushes','issues','prs','merged_prs') and value > 0.2 * 1.0 * sqrt(24.000000/1450.0))
), data as (
  select
  'hdev_' || metric || ',All_All' as metric,
  author || '$$$' || company as name,
  author,
  company,
  value as value
from
  all_all
union
select
  'hdev_' || metric || ',' || repo_group || '_All' as metric,
  author || '$$$' || company as name,
  author,
  company,
  value as value
from
  rg_all
union
select
  'hdev_' || metric || ',All_' || country as metric,
  author || '$$$' || company as name,
  author,
  company,
  value as value
from
  country_all
union
select
  'hdev_' || metric || ',' || repo_group || '_' || country as metric,
  author || '$$$' || company as name,
  author,
  company,
  value as value
from
  rg_country
)
-- order by
--   metric asc,
--   value desc,
--   name asc
select
  author,
  company,
  value
from
  data
where
  metric = 'hdev_contributions,All_All'
  and value > 0
order by
  value desc,
  author asc
;

