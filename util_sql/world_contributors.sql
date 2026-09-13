select
  now() as "time",
  round(sqrt(count(distinct sub.login)::numeric), 0) as "value",
  coalesce(sub.country_id, '') as "name"
from (
  select
    a.login,
    e.id as event_id,
    coalesce(a.country_id, '') as country_id
  from
    gha_actors a,
    gha_events e,
    gha_repos r
  where
    e.repo_id = r.id
    and e.dup_repo_name = r.name
    and r.repo_group in ('Kubernetes')
    and e.dup_actor_login = a.login
    and e.type in ('IssuesEvent', 'PullRequestEvent', 'PushEvent', 'PullRequestReviewCommentEvent', 'IssueCommentEvent', 'CommitCommentEvent')
    and e.created_at BETWEEN '2011-12-31T23:00:00Z' AND '2023-02-03T05:47:12.199Z'
    and (e.dup_actor_login in (null) or 'null' = 'null')
    and lower(a.login) not like all(array['alighrobot', 'angular-builds', 'appveyorbot', 'architectbot', 'asfgit', 'athenabot', 'atlantisbot', 'auto', 'blueorangutan', 'bosh-ci-push-pull', 'cadvisorjenkinsbot', 'cf-buildpacks-eng', 'changelogbot', 'claude', 'clrbuilder', 'codex', 'containersshbuilder', 'coreosbot', 'covbot', 'coveralls', 'cubic-dev-ai', 'devolutionsbot', 'devstats-sync', 'dosu', 'fermybot', 'fluxcdbot', 'fossabot', 'gemini-code-assist', 'getporterbot', 'gitcoinbot', 'github-cncf-landscape-notifs', 'github-harold_pins', 'goodluckbot', 'googlebot', 'goreleaserbot', 'gprasath', 'greptileai', 'infraq', 'invalid-email-address', 'kaipilotbot', 'katacontainersbot', 'kernelprbot', 'kuasar-io-dev', 'kubescapebot', 'litmusbot', 'megaeasex', 'nsmbot', 'openebs-pro-sa', 'openfeaturebot', 'openssl-machine', 'opencontrail-ci-admin', 'opentelemetrybot', 'ovsrobot', 'pckgrbot', 'pikbot', 'podmanbot', 'poiana', 'pouchrobot', 'prowbot', 'rktbot', 'securitylab-codeanalysis', 'sizebot', 'sourcery-ai', 'spinframeworkbot', 'spinnakerbot', 'startxfr', 'stateful-wombot', 'streamnativebot', 'thelinuxfoundation', 'thinkbotbot', 'ti-srebot', 'titanium-octobot', 'travisbuddy', 'tremorbot', 'unownbot', 'web-flow', 'weblate', 'wingetbot', 'zephyr-github', 'zephyrbot', 'actions%', 'claassistant%', 'cncf-bot%', 'codecov%', 'coderabbit%', 'copilot%', 'dependabot%', 'github %', 'github-action%', 'imgbot%', 'jenkins-%', 'k8s-%', 'mergify%', 'qodo-%', 'snyk%', 'strimzi%', 'svc%', 'travis%bot', 'prom%bot', '%-bot', '%-robot', '%bot-%', '%[%bot]%', '%ci%bot', '%cla%bot%', '%autobot', '%buildbot%', '%copybara%', '%renovate%', '%envoy-filter-example%', '%automat%', '%agent', '%-ci', '%-gerrit', '%-infra', '%-jenkins', '%-release', '%-service%', '%-team%', '%-testing', '% bot', '% ci', '% team'])
  union select
    a.login,
    c.event_id,
    coalesce(a.country_id, '') as country_id
  from
    gha_actors a,
    gha_commits c,
    gha_repos r
  where
    c.dup_repo_id = r.id
    and c.dup_repo_name = r.name
    and r.repo_group in ('Kubernetes')
    and c.dup_author_login = a.login
    and c.dup_created_at BETWEEN '2011-12-31T23:00:00Z' AND '2023-02-03T05:47:12.199Z'
    and (c.dup_author_login in (null) or 'null' = 'null')
    and lower(a.login) not like all(array['alighrobot', 'angular-builds', 'appveyorbot', 'architectbot', 'asfgit', 'athenabot', 'atlantisbot', 'auto', 'blueorangutan', 'bosh-ci-push-pull', 'cadvisorjenkinsbot', 'cf-buildpacks-eng', 'changelogbot', 'claude', 'clrbuilder', 'codex', 'containersshbuilder', 'coreosbot', 'covbot', 'coveralls', 'cubic-dev-ai', 'devolutionsbot', 'devstats-sync', 'dosu', 'fermybot', 'fluxcdbot', 'fossabot', 'gemini-code-assist', 'getporterbot', 'gitcoinbot', 'github-cncf-landscape-notifs', 'github-harold_pins', 'goodluckbot', 'googlebot', 'goreleaserbot', 'gprasath', 'greptileai', 'infraq', 'invalid-email-address', 'kaipilotbot', 'katacontainersbot', 'kernelprbot', 'kuasar-io-dev', 'kubescapebot', 'litmusbot', 'megaeasex', 'nsmbot', 'openebs-pro-sa', 'openfeaturebot', 'openssl-machine', 'opencontrail-ci-admin', 'opentelemetrybot', 'ovsrobot', 'pckgrbot', 'pikbot', 'podmanbot', 'poiana', 'pouchrobot', 'prowbot', 'rktbot', 'securitylab-codeanalysis', 'sizebot', 'sourcery-ai', 'spinframeworkbot', 'spinnakerbot', 'startxfr', 'stateful-wombot', 'streamnativebot', 'thelinuxfoundation', 'thinkbotbot', 'ti-srebot', 'titanium-octobot', 'travisbuddy', 'tremorbot', 'unownbot', 'web-flow', 'weblate', 'wingetbot', 'zephyr-github', 'zephyrbot', 'actions%', 'claassistant%', 'cncf-bot%', 'codecov%', 'coderabbit%', 'copilot%', 'dependabot%', 'github %', 'github-action%', 'imgbot%', 'jenkins-%', 'k8s-%', 'mergify%', 'qodo-%', 'snyk%', 'strimzi%', 'svc%', 'travis%bot', 'prom%bot', '%-bot', '%-robot', '%bot-%', '%[%bot]%', '%ci%bot', '%cla%bot%', '%autobot', '%buildbot%', '%copybara%', '%renovate%', '%envoy-filter-example%', '%automat%', '%agent', '%-ci', '%-gerrit', '%-infra', '%-jenkins', '%-release', '%-service%', '%-team%', '%-testing', '% bot', '% ci', '% team'])
  union select
    a.login,
    c.event_id,
    coalesce(a.country_id, '') as country_id
  from
    gha_actors a,
    gha_commits c,
    gha_repos r
  where
    c.dup_repo_id = r.id
    and c.dup_repo_name = r.name
    and r.repo_group in ('Kubernetes')
    and c.dup_committer_login = a.login
    and c.dup_created_at BETWEEN '2011-12-31T23:00:00Z' AND '2023-02-03T05:47:12.199Z'
    and (c.dup_committer_login in (null) or 'null' = 'null')
    and lower(a.login) not like all(array['alighrobot', 'angular-builds', 'appveyorbot', 'architectbot', 'asfgit', 'athenabot', 'atlantisbot', 'auto', 'blueorangutan', 'bosh-ci-push-pull', 'cadvisorjenkinsbot', 'cf-buildpacks-eng', 'changelogbot', 'claude', 'clrbuilder', 'codex', 'containersshbuilder', 'coreosbot', 'covbot', 'coveralls', 'cubic-dev-ai', 'devolutionsbot', 'devstats-sync', 'dosu', 'fermybot', 'fluxcdbot', 'fossabot', 'gemini-code-assist', 'getporterbot', 'gitcoinbot', 'github-cncf-landscape-notifs', 'github-harold_pins', 'goodluckbot', 'googlebot', 'goreleaserbot', 'gprasath', 'greptileai', 'infraq', 'invalid-email-address', 'kaipilotbot', 'katacontainersbot', 'kernelprbot', 'kuasar-io-dev', 'kubescapebot', 'litmusbot', 'megaeasex', 'nsmbot', 'openebs-pro-sa', 'openfeaturebot', 'openssl-machine', 'opencontrail-ci-admin', 'opentelemetrybot', 'ovsrobot', 'pckgrbot', 'pikbot', 'podmanbot', 'poiana', 'pouchrobot', 'prowbot', 'rktbot', 'securitylab-codeanalysis', 'sizebot', 'sourcery-ai', 'spinframeworkbot', 'spinnakerbot', 'startxfr', 'stateful-wombot', 'streamnativebot', 'thelinuxfoundation', 'thinkbotbot', 'ti-srebot', 'titanium-octobot', 'travisbuddy', 'tremorbot', 'unownbot', 'web-flow', 'weblate', 'wingetbot', 'zephyr-github', 'zephyrbot', 'actions%', 'claassistant%', 'cncf-bot%', 'codecov%', 'coderabbit%', 'copilot%', 'dependabot%', 'github %', 'github-action%', 'imgbot%', 'jenkins-%', 'k8s-%', 'mergify%', 'qodo-%', 'snyk%', 'strimzi%', 'svc%', 'travis%bot', 'prom%bot', '%-bot', '%-robot', '%bot-%', '%[%bot]%', '%ci%bot', '%cla%bot%', '%autobot', '%buildbot%', '%copybara%', '%renovate%', '%envoy-filter-example%', '%automat%', '%agent', '%-ci', '%-gerrit', '%-infra', '%-jenkins', '%-release', '%-service%', '%-team%', '%-testing', '% bot', '% ci', '% team'])
) sub
where
  sub.country_id != ''
group by
  sub.country_id
;
