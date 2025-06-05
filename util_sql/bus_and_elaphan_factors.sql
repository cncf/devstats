with commits_data as (
  select r.repo_group as repo_group,
    c.sha,
    lower(c.dup_actor_login) as actor_login,
    coalesce(aa.company_name, '') as company
  from
    gha_repos r,
    gha_commits c
  left join
    gha_actors_affiliations aa
  on
    aa.actor_id = c.dup_actor_id
    and aa.dt_from <= c.dup_created_at
    and aa.dt_to > c.dup_created_at
  where
    c.dup_repo_id = r.id
    and c.dup_repo_name = r.name
    and  (c.dup_created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  union select r.repo_group as repo_group,
    c.sha,
    lower(c.dup_author_login) as actor_login,
    coalesce(aa.company_name, '') as company
  from
    gha_repos r,
    gha_commits c
  left join
    gha_actors_affiliations aa
  on
    aa.actor_id = c.author_id
    and aa.dt_from <= c.dup_created_at
    and aa.dt_to > c.dup_created_at
  where
    c.dup_repo_id = r.id
    and c.dup_repo_name = r.name
    and c.author_id is not null
    and  (c.dup_created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  union select r.repo_group as repo_group,
    c.sha,
    lower(c.dup_committer_login) as actor_login,
    coalesce(aa.company_name, '') as company
  from
    gha_repos r,
    gha_commits c
  left join
    gha_actors_affiliations aa
  on
    aa.actor_id = c.committer_id
    and aa.dt_from <= c.dup_created_at
    and aa.dt_to > c.dup_created_at
  where
    c.dup_repo_id = r.id
    and c.dup_repo_name = r.name
    and c.committer_id is not null
    and  (c.dup_created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  union select r.repo_group as repo_group,
    cr.sha,
    lower(cr.actor_login) as actor_login,
    coalesce(aa.company_name, '') as company
  from
    gha_repos r,
    gha_commits_roles cr
  left join
    gha_actors_affiliations aa
  on
    aa.actor_id = cr.actor_id
    and aa.dt_from <= cr.dup_created_at
    and aa.dt_to > cr.dup_created_at
  where
    cr.dup_repo_id = r.id
    and cr.dup_repo_name = r.name
    and cr.actor_id is not null
    and cr.actor_id != 0
    and cr.role = 'Co-authored-by'
    and  (cr.dup_created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
), org as (
  select
    row_number() over (
      partition by
        repo_group
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_text(sha)))) desc
    ) as row_number,
    repo_group,
    'commits' as metric,
    'org' as tp,
    company as name,
    round(hll_cardinality(hll_add_agg(hll_hash_text(sha)))) as cnt
  from
    commits_data
  where
    company != ''
  group by
    repo_group,
    company
  union select
    row_number() over (
      partition by
        r.repo_group
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.id)))) desc
    ) as row_number,
    r.repo_group,
    'contributions' as metric,
    'org' as tp,
    aa.company_name as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.id)))) as cnt
  from
    gha_events e,
    gha_repos r,
    gha_actors_affiliations aa
  where
    r.name = e.dup_repo_name
    and r.id = e.repo_id
    and e.actor_id = aa.actor_id
    and aa.dt_from <= e.created_at
    and aa.dt_to > e.created_at
    and e.type in (
      'IssuesEvent', 'PullRequestEvent', 'PushEvent',
      'PullRequestReviewCommentEvent', 'IssueCommentEvent',
      'CommitCommentEvent', 'ForkEvent', 'WatchEvent', 'PullRequestReviewEvent'
    )
    and aa.company_name != ''
    and  (e.created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    r.repo_group,
    aa.company_name
  union select
    row_number() over (
      partition by
        r.repo_group,
        e.type
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.id)))) desc
    ) as row_number,
    r.repo_group,
    case e.type
      when 'PushEvent' then 'pushes'
      when 'PullRequestReviewCommentEvent' then 'review_comments'
      when 'PullRequestReviewEvent' then 'reviews'
      when 'IssueCommentEvent' then 'issue_comments'
      when 'CommitCommentEvent' then 'commit_comments'
    end as metric,
    'org' as tp,
    aa.company_name as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.id)))) as cnt
  from
    gha_events e,
    gha_repos r,
    gha_actors_affiliations aa
  where
    r.name = e.dup_repo_name
    and r.id = e.repo_id
    and aa.actor_id = e.actor_id
    and aa.dt_from <= e.created_at
    and aa.dt_to > e.created_at
    and e.type in (
      'PushEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent',
      'IssueCommentEvent', 'CommitCommentEvent'
    )
    and aa.company_name != ''
    and  (e.created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    r.repo_group,
    aa.company_name,
    e.type
  union select
    row_number() over (
      partition by
        r.repo_group
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.repo_id)))) desc
    ) as row_number,
    r.repo_group,
    'active_repos' as metric,
    'org' as tp,
    aa.company_name as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.repo_id)))) as cnt
  from
    gha_events e,
    gha_repos r,
    gha_actors_affiliations aa
  where
    r.name = e.dup_repo_name
    and r.id = e.repo_id
    and aa.actor_id = e.actor_id
    and aa.dt_from <= e.created_at
    and aa.dt_to > e.created_at
    and aa.company_name != ''
    and  (e.created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    r.repo_group,
    aa.company_name
  union select
    row_number() over (
      partition by
        r.repo_group
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(c.id)))) desc
    ) as row_number,
    r.repo_group,
    'comments' as metric,
    'org' as tp,
    aa.company_name as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(c.id)))) as cnt
  from
    gha_repos r,
    gha_comments c,
    gha_actors_affiliations aa
  where
    r.name = c.dup_repo_name
    and r.id = c.dup_repo_id
    and aa.actor_id = c.user_id
    and aa.dt_from <= c.created_at
    and aa.dt_to > c.created_at
    and aa.company_name != ''
    and  (c.created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    r.repo_group,
    aa.company_name
  union select
    row_number() over (
      partition by
        r.repo_group
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(i.id)))) desc
    ) as row_number,
    r.repo_group,
    'issues' as metric,
    'org' as tp,
    aa.company_name as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(i.id)))) as cnt
  from
    gha_repos r,
    gha_issues i,
    gha_actors_affiliations aa
  where
    r.name = i.dup_repo_name
    and r.id = i.dup_repo_id
    and aa.actor_id = i.user_id
    and aa.dt_from <= i.created_at
    and aa.dt_to > i.created_at
    and aa.company_name != ''
    and i.is_pull_request = false
    and  (i.created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    r.repo_group,
    aa.company_name
  union select
    row_number() over (
      partition by
        r.repo_group
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(i.id)))) desc
    ) as row_number,
    r.repo_group,
    'prs' as metric,
    'org' as tp,
    aa.company_name as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(i.id)))) as cnt
  from
    gha_repos r,
    gha_issues i,
    gha_actors_affiliations aa
  where
    r.name = i.dup_repo_name
    and r.id = i.dup_repo_id
    and aa.actor_id = i.user_id
    and aa.dt_from <= i.created_at
    and aa.dt_to > i.created_at
    and aa.company_name != ''
    and i.is_pull_request = true
    and  (i.created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    r.repo_group,
    aa.company_name
  union select
    row_number() over (
      partition by
        r.repo_group
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(i.id)))) desc
    ) as row_number,
    r.repo_group,
    'merged_prs' as metric,
    'org' as tp,
    aa.company_name as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(i.id)))) as cnt
  from
    gha_repos r,
    gha_pull_requests i,
    gha_actors_affiliations aa
  where
    r.name = i.dup_repo_name
    and r.id = i.dup_repo_id
    and aa.actor_id = i.user_id
    and i.merged_at is not null
    and aa.dt_from <= i.merged_at
    and aa.dt_to > i.merged_at
    and aa.company_name != ''
    and  (i.merged_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    r.repo_group,
    aa.company_name
  union select
    row_number() over (
      partition by
        r.repo_group
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.id)))) desc
    ) as row_number,
    r.repo_group,
    'events' as metric,
    'org' as tp,
    aa.company_name as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.id)))) as cnt
  from
    gha_repos r,
    gha_events e,
    gha_actors_affiliations aa
  where
    r.name = e.dup_repo_name
    and r.id = e.repo_id
    and aa.actor_id = e.actor_id
    and aa.dt_from <= e.created_at
    and aa.dt_to > e.created_at
    and aa.company_name != ''
    and  (e.created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    r.repo_group,
    aa.company_name
  union select
    row_number() over (
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_text(sha)))) desc
    ) as row_number,
    'All',
    'commits' as metric,
    'org' as tp,
    company as name,
    round(hll_cardinality(hll_add_agg(hll_hash_text(sha)))) as cnt
  from
    commits_data
  where
    company != ''
  group by
    company
  union select
    row_number() over (
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.id)))) desc
    ) as row_number,
    'All',
    'contributions' as metric,
    'org' as tp,
    aa.company_name as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.id)))) as cnt
  from
    gha_events e,
    gha_repos r,
    gha_actors_affiliations aa
  where
    r.name = e.dup_repo_name
    and r.id = e.repo_id
    and e.actor_id = aa.actor_id
    and aa.dt_from <= e.created_at
    and aa.dt_to > e.created_at
    and e.type in (
      'IssuesEvent', 'PullRequestEvent', 'PushEvent',
      'PullRequestReviewCommentEvent', 'IssueCommentEvent',
      'CommitCommentEvent', 'ForkEvent', 'WatchEvent', 'PullRequestReviewEvent'
    )
    and aa.company_name != ''
    and  (e.created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    aa.company_name
  union select
    row_number() over (
      partition by
        e.type
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.id)))) desc
    ) as row_number,
    'All',
    case e.type
      when 'PushEvent' then 'pushes'
      when 'PullRequestReviewCommentEvent' then 'review_comments'
      when 'PullRequestReviewEvent' then 'reviews'
      when 'IssueCommentEvent' then 'issue_comments'
      when 'CommitCommentEvent' then 'commit_comments'
    end as metric,
    'org' as tp,
    aa.company_name as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.id)))) as cnt
  from
    gha_events e,
    gha_repos r,
    gha_actors_affiliations aa
  where
    r.name = e.dup_repo_name
    and r.id = e.repo_id
    and aa.actor_id = e.actor_id
    and aa.dt_from <= e.created_at
    and aa.dt_to > e.created_at
    and e.type in (
      'PushEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent',
      'IssueCommentEvent', 'CommitCommentEvent'
    )
    and aa.company_name != ''
    and  (e.created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    aa.company_name,
    e.type
  union select
    row_number() over (
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.repo_id)))) desc
    ) as row_number,
    'All',
    'active_repos' as metric,
    'org' as tp,
    aa.company_name as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.repo_id)))) as cnt
  from
    gha_events e,
    gha_repos r,
    gha_actors_affiliations aa
  where
    r.name = e.dup_repo_name
    and r.id = e.repo_id
    and aa.actor_id = e.actor_id
    and aa.dt_from <= e.created_at
    and aa.dt_to > e.created_at
    and aa.company_name != ''
    and  (e.created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    aa.company_name
  union select
    row_number() over (
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(c.id)))) desc
    ) as row_number,
    'All',
    'comments' as metric,
    'org' as tp,
    aa.company_name as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(c.id)))) as cnt
  from
    gha_repos r,
    gha_comments c,
    gha_actors_affiliations aa
  where
    r.name = c.dup_repo_name
    and r.id = c.dup_repo_id
    and aa.actor_id = c.user_id
    and aa.dt_from <= c.created_at
    and aa.dt_to > c.created_at
    and aa.company_name != ''
    and  (c.created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    aa.company_name
  union select
    row_number() over (
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(i.id)))) desc
    ) as row_number,
    'All',
    'issues' as metric,
    'org' as tp,
    aa.company_name as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(i.id)))) as cnt
  from
    gha_repos r,
    gha_issues i,
    gha_actors_affiliations aa
  where
    r.name = i.dup_repo_name
    and r.id = i.dup_repo_id
    and aa.actor_id = i.user_id
    and aa.dt_from <= i.created_at
    and aa.dt_to > i.created_at
    and aa.company_name != ''
    and i.is_pull_request = false
    and  (i.created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    aa.company_name
  union select
    row_number() over (
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(i.id)))) desc
    ) as row_number,
    'All',
    'prs' as metric,
    'org' as tp,
    aa.company_name as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(i.id)))) as cnt
  from
    gha_repos r,
    gha_issues i,
    gha_actors_affiliations aa
  where
    r.name = i.dup_repo_name
    and r.id = i.dup_repo_id
    and aa.actor_id = i.user_id
    and aa.dt_from <= i.created_at
    and aa.dt_to > i.created_at
    and aa.company_name != ''
    and i.is_pull_request = true
    and  (i.created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    aa.company_name
  union select
    row_number() over (
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(i.id)))) desc
    ) as row_number,
    'All',
    'merged_prs' as metric,
    'org' as tp,
    aa.company_name as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(i.id)))) as cnt
  from
    gha_repos r,
    gha_pull_requests i,
    gha_actors_affiliations aa
  where
    r.name = i.dup_repo_name
    and r.id = i.dup_repo_id
    and aa.actor_id = i.user_id
    and i.merged_at is not null
    and aa.dt_from <= i.merged_at
    and aa.dt_to > i.merged_at
    and aa.company_name != ''
    and  (i.merged_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    aa.company_name
  union select
    row_number() over (
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.id)))) desc
    ) as row_number,
    'All',
    'events' as metric,
    'org' as tp,
    aa.company_name as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.id)))) as cnt
  from
    gha_repos r,
    gha_events e,
    gha_actors_affiliations aa
  where
    r.name = e.dup_repo_name
    and r.id = e.repo_id
    and aa.actor_id = e.actor_id
    and aa.dt_from <= e.created_at
    and aa.dt_to > e.created_at
    and aa.company_name != ''
    and  (e.created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    aa.company_name
), urg as (
  select
    row_number() over (
      partition by
        repo_group
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_text(sha)))) desc
    ) as row_number,
    repo_group,
    'commits' as metric,
    'usr' as tp,
    actor_login as name,
    round(hll_cardinality(hll_add_agg(hll_hash_text(sha)))) as cnt
  from
    commits_data
  group by
    repo_group,
    actor_login
  union select
    row_number() over (
      partition by
        r.repo_group
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.id)))) desc
    ) as row_number,
    r.repo_group,
    'contributions' as metric,
    'usr' as tp,
    e.dup_actor_login as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.id)))) as cnt
  from
    gha_events e,
    gha_repos r
  where
    r.name = e.dup_repo_name
    and r.id = e.repo_id
    and e.type in (
      'IssuesEvent', 'PullRequestEvent', 'PushEvent',
      'PullRequestReviewCommentEvent', 'IssueCommentEvent',
      'CommitCommentEvent', 'ForkEvent', 'WatchEvent', 'PullRequestReviewEvent'
    )
    and  (e.created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    r.repo_group,
    e.dup_actor_login
  union select
    row_number() over (
      partition by
        r.repo_group,
        e.type
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.id)))) desc
    ) as row_number,
    r.repo_group,
    case e.type
      when 'PushEvent' then 'pushes'
      when 'PullRequestReviewCommentEvent' then 'review_comments'
      when 'PullRequestReviewEvent' then 'reviews'
      when 'IssueCommentEvent' then 'issue_comments'
      when 'CommitCommentEvent' then 'commit_comments'
    end as metric,
    'usr' as tp,
    e.dup_actor_login as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.id)))) as cnt
  from
    gha_events e,
    gha_repos r
  where
    r.name = e.dup_repo_name
    and r.id = e.repo_id
    and e.type in (
      'PushEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent',
      'IssueCommentEvent', 'CommitCommentEvent'
    )
    and  (e.created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    r.repo_group,
    e.dup_actor_login,
    e.type
  union select
    row_number() over (
      partition by
        r.repo_group
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.repo_id)))) desc
    ) as row_number,
    r.repo_group,
    'active_repos' as metric,
    'usr' as tp,
    e.dup_actor_login as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.repo_id)))) as cnt
  from
    gha_events e,
    gha_repos r
  where
    r.name = e.dup_repo_name
    and r.id = e.repo_id
    and  (e.created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    r.repo_group,
    e.dup_actor_login
  union select
    row_number() over (
      partition by
        r.repo_group
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(c.id)))) desc
    ) as row_number,
    r.repo_group,
    'comments' as metric,
    'usr' as tp,
    c.dup_user_login as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(c.id)))) as cnt
  from
    gha_repos r,
    gha_comments c
  where
    r.name = c.dup_repo_name
    and r.id = c.dup_repo_id
    and  (c.created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    r.repo_group,
    c.dup_user_login
  union select
    row_number() over (
      partition by
        r.repo_group
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(i.id)))) desc
    ) as row_number,
    r.repo_group,
    'issues' as metric,
    'usr' as tp,
    i.dup_user_login as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(i.id)))) as cnt
  from
    gha_repos r,
    gha_issues i
  where
    r.name = i.dup_repo_name
    and r.id = i.dup_repo_id
    and i.is_pull_request = false
    and  (i.created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    r.repo_group,
    i.dup_user_login
  union select
    row_number() over (
      partition by
        r.repo_group
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(i.id)))) desc
    ) as row_number,
    r.repo_group,
    'prs' as metric,
    'usr' as tp,
    i.dup_user_login as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(i.id)))) as cnt
  from
    gha_repos r,
    gha_issues i
  where
    r.name = i.dup_repo_name
    and r.id = i.dup_repo_id
    and i.is_pull_request = true
    and  (i.created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    r.repo_group,
    i.dup_user_login
  union select
    row_number() over (
      partition by
        r.repo_group
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(i.id)))) desc
    ) as row_number,
    r.repo_group,
    'merged_prs' as metric,
    'usr' as tp,
    i.dup_user_login as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(i.id)))) as cnt
  from
    gha_repos r,
    gha_pull_requests i
  where
    r.name = i.dup_repo_name
    and r.id = i.dup_repo_id
    and i.merged_at is not null
    and  (i.merged_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    r.repo_group,
    i.dup_user_login
  union select
    row_number() over (
      partition by
        r.repo_group
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.id)))) desc
    ) as row_number,
    r.repo_group,
    'events' as metric,
    'usr' as tp,
    e.dup_actor_login as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.id)))) as cnt
  from
    gha_repos r,
    gha_events e
  where
    r.name = e.dup_repo_name
    and r.id = e.repo_id
    and  (e.created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    r.repo_group,
    e.dup_actor_login
  union select
    row_number() over (
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_text(sha)))) desc
    ) as row_number,
    'All',
    'commits' as metric,
    'usr' as tp,
    actor_login as name,
    round(hll_cardinality(hll_add_agg(hll_hash_text(sha)))) as cnt
  from
    commits_data
  group by
    actor_login
  union select
    row_number() over (
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.id)))) desc
    ) as row_number,
    'All',
    'contributions' as metric,
    'usr' as tp,
    e.dup_actor_login as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.id)))) as cnt
  from
    gha_events e,
    gha_repos r
  where
    r.name = e.dup_repo_name
    and r.id = e.repo_id
    and e.type in (
      'IssuesEvent', 'PullRequestEvent', 'PushEvent',
      'PullRequestReviewCommentEvent', 'IssueCommentEvent',
      'CommitCommentEvent', 'ForkEvent', 'WatchEvent', 'PullRequestReviewEvent'
    )
    and  (e.created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    e.dup_actor_login
  union select
    row_number() over (
      partition by
        e.type
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.id)))) desc
    ) as row_number,
    'All',
    case e.type
      when 'PushEvent' then 'pushes'
      when 'PullRequestReviewCommentEvent' then 'review_comments'
      when 'PullRequestReviewEvent' then 'reviews'
      when 'IssueCommentEvent' then 'issue_comments'
      when 'CommitCommentEvent' then 'commit_comments'
    end as metric,
    'usr' as tp,
    e.dup_actor_login as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.id)))) as cnt
  from
    gha_events e,
    gha_repos r
  where
    r.name = e.dup_repo_name
    and r.id = e.repo_id
    and e.type in (
      'PushEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent',
      'IssueCommentEvent', 'CommitCommentEvent'
    )
    and  (e.created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    e.dup_actor_login,
    e.type
  union select
    row_number() over (
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.repo_id)))) desc
    ) as row_number,
    'All',
    'active_repos' as metric,
    'usr' as tp,
    e.dup_actor_login as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.repo_id)))) as cnt
  from
    gha_events e,
    gha_repos r
  where
    r.name = e.dup_repo_name
    and r.id = e.repo_id
    and  (e.created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    e.dup_actor_login
  union select
    row_number() over (
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(c.id)))) desc
    ) as row_number,
    'All',
    'comments' as metric,
    'usr' as tp,
    c.dup_user_login as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(c.id)))) as cnt
  from
    gha_repos r,
    gha_comments c
  where
    r.name = c.dup_repo_name
    and r.id = c.dup_repo_id
    and  (c.created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    c.dup_user_login
  union select
    row_number() over (
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(i.id)))) desc
    ) as row_number,
    'All',
    'issues' as metric,
    'usr' as tp,
    i.dup_user_login as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(i.id)))) as cnt
  from
    gha_repos r,
    gha_issues i
  where
    r.name = i.dup_repo_name
    and r.id = i.dup_repo_id
    and i.is_pull_request = false
    and  (i.created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    i.dup_user_login
  union select
    row_number() over (
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(i.id)))) desc
    ) as row_number,
    'All',
    'prs' as metric,
    'usr' as tp,
    i.dup_user_login as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(i.id)))) as cnt
  from
    gha_repos r,
    gha_issues i
  where
    r.name = i.dup_repo_name
    and r.id = i.dup_repo_id
    and i.is_pull_request = true
    and  (i.created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    i.dup_user_login
  union select
    row_number() over (
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(i.id)))) desc
    ) as row_number,
    'All',
    'merged_prs' as metric,
    'usr' as tp,
    i.dup_user_login as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(i.id)))) as cnt
  from
    gha_repos r,
    gha_pull_requests i
  where
    r.name = i.dup_repo_name
    and r.id = i.dup_repo_id
    and i.merged_at is not null
    and  (i.merged_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    i.dup_user_login
  union select
    row_number() over (
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.id)))) desc
    ) as row_number,
    'All',
    'events' as metric,
    'usr' as tp,
    e.dup_actor_login as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.id)))) as cnt
  from
    gha_repos r,
    gha_events e
  where
    r.name = e.dup_repo_name
    and r.id = e.repo_id
    and  (e.created_at >= now() - '1 week'::interval) 
    and (lower(e.dup_actor_login) not like all(array['openebs-pro-sa', 'stateful-wombot', 'fermybot', 'opentofu-provider-sync-service-account', 'flatcar-infra', 'atlantisbot', 'megaeasex', 'kuasar-io-dev', 'startxfr', 'opentelemetrybot', 'invalid-email-address', 'fluxcdbot', 'claassistant', 'containersshbuilder', 'wasmcloud-automation', 'fossabot', 'facebook-github-whois-bot-0', 'knative-automation', 'covbot', 'cdk8s-automation', 'github-action-benchmark', 'goreleaserbot', 'imgbotapp', 'backstage-service', 'openssl-machine', 'sizebot', 'dependabot', 'cncf-ci', 'poiana', 'svcbot-qecnsdp', 'nsmbot', 'ti-srebot', 'cf-buildpacks-eng', 'bosh-ci-push-pull', 'gprasath', 'zephyr-github', 'zephyrbot', 'strimzi-ci', 'athenabot', 'k8s-reviewable', 'codecov-io', 'grpc-testing', 'k8s-teamcity-mesosphere', 'angular-builds', 'devstats-sync', 'googlebot', 'hibernate-ci', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'prometheus-roobot', 'cncf-bot', 'kernelprbot', 'istio-testing', 'spinnakerbot', 'pikbot', 'spinnaker-release', 'golangcibot', 'opencontrail-ci-admin', 'titanium-octobot', 'asfgit', 'appveyorbot', 'cadvisorjenkinsbot', 'gitcoinbot', 'katacontainersbot', 'prombot', 'prowbot', 'travis%bot', 'k8s-%', '%-bot', '%-robot', 'bot-%', 'robot-%', '%[bot]%', '%[robot]%', '%-jenkins', 'jenkins-%', '%-ci%bot', '%-testing', 'codecov-%', '%clabot%', '%cla-bot%', '%-gerrit', '%-bot-%', '%envoy-filter-example%', '%cibot', '%-ci']))
  group by
    e.dup_actor_login
), rg as (
  select
    row_number,
    repo_group,
    metric,
    tp,
    name,
    cnt
  from
    org
  union select
    row_number,
    repo_group,
    metric,
    tp,
    name,
    cnt
  from
    urg
  order by
    metric,
    tp,
    repo_group,
    cnt desc
), all_rg as (
  select
    repo_group,
    metric,
    tp,
    sum(cnt) as cnt
  from
    rg
  group by
    repo_group,
    metric,
    tp
), cum_rg as (
  select
    r.repo_group,
    r.metric,
    r.tp,
    r.row_number,
    r.cnt,
    r.name,
    100.0 * r.cnt / (case ar.cnt when 0 then 1 else ar.cnt end) as percent,
    (100.0 * sum(r.cnt) over (
      partition by
        r.repo_group,
        r.metric,
        r.tp
      order by
        r.row_number asc
      rows between unbounded preceding and current row
    )) / (case r.cnt when 0 then 1 else ar.cnt end) as cumulative_percent
  from
    rg r
  inner join
    all_rg ar
  on
    r.repo_group = ar.repo_group
    and r.metric = ar.metric
    and r.tp = ar.tp
  order by
    r.repo_group,
    r.metric,
    r.tp,
    r.row_number
), bf as (
  select
    repo_group,
    metric,
    tp,
    min(row_number) as bus_factor,
    min(cumulative_percent) as percent,
    max(row_number) - min(row_number) as others_count,
    100.0 - min(cumulative_percent) as others_percent
  from
    cum_rg
  where
    cumulative_percent > 50.0
  group by
    repo_group,
    metric,
    tp
), bfc as (
  select
    b.repo_group,
    b.metric,
    b.tp,
    string_agg(cr.name, ', ') over (
      partition by
        b.repo_group,
        b.metric,
        b.tp
      order by
        cr.row_number
    ) as companies
  from
    bf b,
    cum_rg cr
  where
    cr.repo_group = b.repo_group
    and cr.metric = b.metric
    and cr.tp = b.tp
    and cr.row_number <= b.bus_factor
    and cr.row_number <= 10
), bfa as (
  select
    b.repo_group,
    b.metric,
    b.tp,
    b.bus_factor,
    b.percent,
    max(c.companies) as companies,
    b.others_count,
    b.others_percent
  from
    bf b,
    bfc c
  where
    b.repo_group = c.repo_group
    and b.metric = c.metric
    and b.tp = c.tp
  group by
    b.repo_group,
    b.metric,
    b.tp,
    b.bus_factor,
    b.percent,
    b.others_count,
    b.others_percent
), top as (
  select
    repo_group,
    metric,
    tp,
    max(row_number) as top_n,
    max(cumulative_percent) as top_percent,
    100.0 - max(cumulative_percent) as non_top_percent
  from
    cum_rg
  where
    row_number <= 10
  group by
    repo_group,
    metric,
    tp
), topc as (
  select
    t.repo_group,
    t.metric,
    t.tp,
    string_agg(cr.name, ', ') over (
      partition by
        t.repo_group,
        t.metric,
        t.tp
      order by
        cr.row_number
    ) as companies
  from
    top t,
    cum_rg cr
  where
    cr.repo_group = t.repo_group
    and cr.metric = t.metric
    and cr.tp = t.tp
    and cr.row_number <= t.top_n
), topa as (
  select
    t.repo_group,
    t.metric,
    t.tp,
    t.top_n,
    t.top_percent,
    max(c.companies) as companies,
    t.non_top_percent
  from
    top t,
    topc c
  where
    t.repo_group = c.repo_group
    and t.metric = c.metric
    and t.tp = c.tp
  group by
    t.repo_group,
    t.metric,
    t.tp,
    t.top_n,
    t.top_percent,
    t.non_top_percent
), final as (
  select
    b.repo_group,
    b.metric,
    b.tp,
    b.bus_factor,
    b.percent as bus_factor_percent,
    b.companies as bus_factor_companies,
    b.others_count,
    b.others_percent,
    t.top_n,
    t.top_percent,
    t.companies as top_companies,
    (b.bus_factor + b.others_count) - t.top_n as non_top_count,
    t.non_top_percent
  from
    bfa b,
    topa t
  where
    b.repo_group = t.repo_group
    and b.metric = t.metric
    and b.tp = t.tp
)
select
  *
from
  final
order by
  repo_group,
  tp,
  metric
;
