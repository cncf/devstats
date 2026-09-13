select
  -- string_agg(sub.actor, ',')
  sub.actor
from (
  select distinct sub2.actor
  from (
    select a.login as actor
    from
      gha_events e,
      gha_actors a
    where
      (e.actor_id = a.id or e.dup_actor_login = a.login)
      and e.type in (
        'PullRequestReviewCommentEvent', 'PushEvent', 'PullRequestEvent',
        'IssuesEvent', 'IssueCommentEvent', 'CommitCommentEvent', 'PullRequestReviewEvent'
      )
      and lower(a.login) not like all(array['alighrobot', 'angular-builds', 'appveyorbot', 'architectbot', 'asfgit', 'athenabot', 'atlantisbot', 'auto', 'blueorangutan', 'bosh-ci-push-pull', 'cadvisorjenkinsbot', 'cf-buildpacks-eng', 'changelogbot', 'claude', 'clrbuilder', 'codex', 'containersshbuilder', 'coreosbot', 'covbot', 'coveralls', 'cubic-dev-ai', 'devolutionsbot', 'devstats-sync', 'dosu', 'fermybot', 'fluxcdbot', 'fossabot', 'gemini-code-assist', 'getporterbot', 'gitcoinbot', 'github-cncf-landscape-notifs', 'github-harold_pins', 'goodluckbot', 'googlebot', 'goreleaserbot', 'gprasath', 'greptileai', 'infraq', 'invalid-email-address', 'kaipilotbot', 'katacontainersbot', 'kernelprbot', 'kuasar-io-dev', 'kubescapebot', 'litmusbot', 'megaeasex', 'nsmbot', 'openebs-pro-sa', 'openfeaturebot', 'openssl-machine', 'opencontrail-ci-admin', 'opentelemetrybot', 'ovsrobot', 'pckgrbot', 'pikbot', 'podmanbot', 'poiana', 'pouchrobot', 'prowbot', 'rktbot', 'securitylab-codeanalysis', 'sizebot', 'sourcery-ai', 'spinframeworkbot', 'spinnakerbot', 'startxfr', 'stateful-wombot', 'streamnativebot', 'thelinuxfoundation', 'thinkbotbot', 'ti-srebot', 'titanium-octobot', 'travisbuddy', 'tremorbot', 'unownbot', 'web-flow', 'weblate', 'wingetbot', 'zephyr-github', 'zephyrbot', 'actions%', 'claassistant%', 'cncf-bot%', 'codecov%', 'coderabbit%', 'copilot%', 'dependabot%', 'github %', 'github-action%', 'imgbot%', 'jenkins-%', 'k8s-%', 'mergify%', 'qodo-%', 'snyk%', 'strimzi%', 'svc%', 'travis%bot', 'prom%bot', '%-bot', '%-robot', '%bot-%', '%[%bot]%', '%ci%bot', '%cla%bot%', '%autobot', '%buildbot%', '%copybara%', '%renovate%', '%envoy-filter-example%', '%automat%', '%agent', '%-ci', '%-gerrit', '%-infra', '%-jenkins', '%-release', '%-service%', '%-team%', '%-testing', '% bot', '% ci', '% team'])
    union select a.login as actor
    from
      gha_commits c,
      gha_actors a
    where
      (c.committer_id = a.id or c.dup_committer_login = a.login)
      and lower(a.login) not like all(array['alighrobot', 'angular-builds', 'appveyorbot', 'architectbot', 'asfgit', 'athenabot', 'atlantisbot', 'auto', 'blueorangutan', 'bosh-ci-push-pull', 'cadvisorjenkinsbot', 'cf-buildpacks-eng', 'changelogbot', 'claude', 'clrbuilder', 'codex', 'containersshbuilder', 'coreosbot', 'covbot', 'coveralls', 'cubic-dev-ai', 'devolutionsbot', 'devstats-sync', 'dosu', 'fermybot', 'fluxcdbot', 'fossabot', 'gemini-code-assist', 'getporterbot', 'gitcoinbot', 'github-cncf-landscape-notifs', 'github-harold_pins', 'goodluckbot', 'googlebot', 'goreleaserbot', 'gprasath', 'greptileai', 'infraq', 'invalid-email-address', 'kaipilotbot', 'katacontainersbot', 'kernelprbot', 'kuasar-io-dev', 'kubescapebot', 'litmusbot', 'megaeasex', 'nsmbot', 'openebs-pro-sa', 'openfeaturebot', 'openssl-machine', 'opencontrail-ci-admin', 'opentelemetrybot', 'ovsrobot', 'pckgrbot', 'pikbot', 'podmanbot', 'poiana', 'pouchrobot', 'prowbot', 'rktbot', 'securitylab-codeanalysis', 'sizebot', 'sourcery-ai', 'spinframeworkbot', 'spinnakerbot', 'startxfr', 'stateful-wombot', 'streamnativebot', 'thelinuxfoundation', 'thinkbotbot', 'ti-srebot', 'titanium-octobot', 'travisbuddy', 'tremorbot', 'unownbot', 'web-flow', 'weblate', 'wingetbot', 'zephyr-github', 'zephyrbot', 'actions%', 'claassistant%', 'cncf-bot%', 'codecov%', 'coderabbit%', 'copilot%', 'dependabot%', 'github %', 'github-action%', 'imgbot%', 'jenkins-%', 'k8s-%', 'mergify%', 'qodo-%', 'snyk%', 'strimzi%', 'svc%', 'travis%bot', 'prom%bot', '%-bot', '%-robot', '%bot-%', '%[%bot]%', '%ci%bot', '%cla%bot%', '%autobot', '%buildbot%', '%copybara%', '%renovate%', '%envoy-filter-example%', '%automat%', '%agent', '%-ci', '%-gerrit', '%-infra', '%-jenkins', '%-release', '%-service%', '%-team%', '%-testing', '% bot', '% ci', '% team'])
    union select a.login as actor
    from
      gha_commits c,
      gha_actors a
    where
      (c.author_id = a.id or c.dup_author_login = a.login)
      and lower(a.login) not like all(array['alighrobot', 'angular-builds', 'appveyorbot', 'architectbot', 'asfgit', 'athenabot', 'atlantisbot', 'auto', 'blueorangutan', 'bosh-ci-push-pull', 'cadvisorjenkinsbot', 'cf-buildpacks-eng', 'changelogbot', 'claude', 'clrbuilder', 'codex', 'containersshbuilder', 'coreosbot', 'covbot', 'coveralls', 'cubic-dev-ai', 'devolutionsbot', 'devstats-sync', 'dosu', 'fermybot', 'fluxcdbot', 'fossabot', 'gemini-code-assist', 'getporterbot', 'gitcoinbot', 'github-cncf-landscape-notifs', 'github-harold_pins', 'goodluckbot', 'googlebot', 'goreleaserbot', 'gprasath', 'greptileai', 'infraq', 'invalid-email-address', 'kaipilotbot', 'katacontainersbot', 'kernelprbot', 'kuasar-io-dev', 'kubescapebot', 'litmusbot', 'megaeasex', 'nsmbot', 'openebs-pro-sa', 'openfeaturebot', 'openssl-machine', 'opencontrail-ci-admin', 'opentelemetrybot', 'ovsrobot', 'pckgrbot', 'pikbot', 'podmanbot', 'poiana', 'pouchrobot', 'prowbot', 'rktbot', 'securitylab-codeanalysis', 'sizebot', 'sourcery-ai', 'spinframeworkbot', 'spinnakerbot', 'startxfr', 'stateful-wombot', 'streamnativebot', 'thelinuxfoundation', 'thinkbotbot', 'ti-srebot', 'titanium-octobot', 'travisbuddy', 'tremorbot', 'unownbot', 'web-flow', 'weblate', 'wingetbot', 'zephyr-github', 'zephyrbot', 'actions%', 'claassistant%', 'cncf-bot%', 'codecov%', 'coderabbit%', 'copilot%', 'dependabot%', 'github %', 'github-action%', 'imgbot%', 'jenkins-%', 'k8s-%', 'mergify%', 'qodo-%', 'snyk%', 'strimzi%', 'svc%', 'travis%bot', 'prom%bot', '%-bot', '%-robot', '%bot-%', '%[%bot]%', '%ci%bot', '%cla%bot%', '%autobot', '%buildbot%', '%copybara%', '%renovate%', '%envoy-filter-example%', '%automat%', '%agent', '%-ci', '%-gerrit', '%-infra', '%-jenkins', '%-release', '%-service%', '%-team%', '%-testing', '% bot', '% ci', '% team'])
    ) sub2
  order by
    sub2.actor asc
  ) sub
;
