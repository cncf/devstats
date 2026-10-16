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
    and lower(a.login) not like all(array['alighrobot', 'amplabjenkins', 'angular-builds', 'appveyorbot', 'architectbot', 'asfgit', 'athenabot', 'atlantisbot', 'auto', 'blackduck-serv-builder', 'blueorangutan', 'bosh-ci-push-pull', 'buildhive', 'cadvisorjenkinsbot', 'cf-buildpacks-eng', 'changelogbot', 'ci', 'claude', 'cloudbees-pull-request-builder', 'clrbuilder', 'codelingobot', 'codex', 'codspeedbot', 'containersshbuilder', 'coreosbot', 'covbot', 'coveralls', 'cubic-dev-ai', 'cvp-ops', 'damn good b0t', 'devolutionsbot', 'devstats-sync', 'dosu', 'ericwittbot', 'fermybot', 'fluxcdbot', 'fossabot', 'gemini-code-assist', 'getporterbot', 'gitcoinbot', 'github-cncf-landscape-notifs', 'github-harold_pins', 'gocursor', 'goodluckbot', 'googlebot', 'gopherbot', 'goreleaserbot', 'gprasath', 'grafanabot', 'greptileai', 'grpc-kokoro', 'heptibot', 'hubot', 'infraq', 'intellij-rainbow-brackets', 'invalid-email-address', 'iptecharch-builder', 'issuehuntbot', 'jenkinsadmin', 'jfrogbot', 'jreleaserbot', 'jsdelivrbot', 'k3aibot', 'kaipilotbot', 'katacontainersbot', 'kernelprbot', 'krkn-chaos', 'kuasar-io-dev', 'kubescapebot', 'l5io', 'letsusegerrit', 'litmusbot', 'maxio', 'megaeasebot', 'megaeasex', 'mentatbot', 'modular-magician', 'monkeycode-ai', 'msftclas', 'msftgits', 'nsmbot', 'oai-codex', 'oceanjxbot', 'opencontrail-ci-admin', 'openebs-pro-sa', 'openfeaturebot', 'openssl-machine', 'opentelemetrybot', 'oss-sentinel-ai', 'oss-taishan-ai', 'otcbot', 'ovsrobot', 'pckgrbot', 'persesbot', 'pikbot', 'podmanbot', 'poiana', 'pouchrobot', 'projectstacker', 'prowbot', 'rancherbot', 'repobirdbot', 'rktbot', 'securitylab-codeanalysis', 'sizebot', 'sourcery-ai', 'spellarbot', 'spinframeworkbot', 'spinnakerbot', 'spinnakerbot2', 'stacklokbot', 'startxfr', 'stateful-wombot', 'streamnativebot', 'thelinuxfoundation', 'thinkbotbot', 'ti-srebot', 'titanium-octobot', 'travisbuddy', 'tremorbot', 'twbs-grunt', 'unownbot', 'vmwghbot', 'vsxen', 'waxobot', 'weaveworksbot', 'web-flow', 'weblate', 'wingetbot', 'yahoocla', 'zephyr-github', 'zephyrbot', 'actions%', 'claassistant%', 'cncf-bot%', 'codecov%', 'coderabbit%', 'copilot%', 'dependabot%', 'github %', 'github-action%', 'imgbot%', 'jenkins-%', 'k8s-%', 'mergify%', 'qodo-%', 'snyk%', 'strimzi%', 'svc%', 'travis%bot', 'prom%bot', 'promptless%', '%-bot', '%-robot', '%bot-%', '%[%bot]%', '%ci%bot', '%cla%bot%', '%autobot', '%buildbot%', '%copybara%', '%renovate%', '%envoy-filter-example%', '%automat%', '%agent', '%-ci', '%-gerrit', '%-infra', '%-jenkins', '%-release', '%-service%', '%-team%', '%-testing', '% bot', '% ci', '% team', '% releaser', '%machine account%'])
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
    and lower(a.login) not like all(array['alighrobot', 'amplabjenkins', 'angular-builds', 'appveyorbot', 'architectbot', 'asfgit', 'athenabot', 'atlantisbot', 'auto', 'blackduck-serv-builder', 'blueorangutan', 'bosh-ci-push-pull', 'buildhive', 'cadvisorjenkinsbot', 'cf-buildpacks-eng', 'changelogbot', 'ci', 'claude', 'cloudbees-pull-request-builder', 'clrbuilder', 'codelingobot', 'codex', 'codspeedbot', 'containersshbuilder', 'coreosbot', 'covbot', 'coveralls', 'cubic-dev-ai', 'cvp-ops', 'damn good b0t', 'devolutionsbot', 'devstats-sync', 'dosu', 'ericwittbot', 'fermybot', 'fluxcdbot', 'fossabot', 'gemini-code-assist', 'getporterbot', 'gitcoinbot', 'github-cncf-landscape-notifs', 'github-harold_pins', 'gocursor', 'goodluckbot', 'googlebot', 'gopherbot', 'goreleaserbot', 'gprasath', 'grafanabot', 'greptileai', 'grpc-kokoro', 'heptibot', 'hubot', 'infraq', 'intellij-rainbow-brackets', 'invalid-email-address', 'iptecharch-builder', 'issuehuntbot', 'jenkinsadmin', 'jfrogbot', 'jreleaserbot', 'jsdelivrbot', 'k3aibot', 'kaipilotbot', 'katacontainersbot', 'kernelprbot', 'krkn-chaos', 'kuasar-io-dev', 'kubescapebot', 'l5io', 'letsusegerrit', 'litmusbot', 'maxio', 'megaeasebot', 'megaeasex', 'mentatbot', 'modular-magician', 'monkeycode-ai', 'msftclas', 'msftgits', 'nsmbot', 'oai-codex', 'oceanjxbot', 'opencontrail-ci-admin', 'openebs-pro-sa', 'openfeaturebot', 'openssl-machine', 'opentelemetrybot', 'oss-sentinel-ai', 'oss-taishan-ai', 'otcbot', 'ovsrobot', 'pckgrbot', 'persesbot', 'pikbot', 'podmanbot', 'poiana', 'pouchrobot', 'projectstacker', 'prowbot', 'rancherbot', 'repobirdbot', 'rktbot', 'securitylab-codeanalysis', 'sizebot', 'sourcery-ai', 'spellarbot', 'spinframeworkbot', 'spinnakerbot', 'spinnakerbot2', 'stacklokbot', 'startxfr', 'stateful-wombot', 'streamnativebot', 'thelinuxfoundation', 'thinkbotbot', 'ti-srebot', 'titanium-octobot', 'travisbuddy', 'tremorbot', 'twbs-grunt', 'unownbot', 'vmwghbot', 'vsxen', 'waxobot', 'weaveworksbot', 'web-flow', 'weblate', 'wingetbot', 'yahoocla', 'zephyr-github', 'zephyrbot', 'actions%', 'claassistant%', 'cncf-bot%', 'codecov%', 'coderabbit%', 'copilot%', 'dependabot%', 'github %', 'github-action%', 'imgbot%', 'jenkins-%', 'k8s-%', 'mergify%', 'qodo-%', 'snyk%', 'strimzi%', 'svc%', 'travis%bot', 'prom%bot', 'promptless%', '%-bot', '%-robot', '%bot-%', '%[%bot]%', '%ci%bot', '%cla%bot%', '%autobot', '%buildbot%', '%copybara%', '%renovate%', '%envoy-filter-example%', '%automat%', '%agent', '%-ci', '%-gerrit', '%-infra', '%-jenkins', '%-release', '%-service%', '%-team%', '%-testing', '% bot', '% ci', '% team', '% releaser', '%machine account%'])
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
    and lower(a.login) not like all(array['alighrobot', 'amplabjenkins', 'angular-builds', 'appveyorbot', 'architectbot', 'asfgit', 'athenabot', 'atlantisbot', 'auto', 'blackduck-serv-builder', 'blueorangutan', 'bosh-ci-push-pull', 'buildhive', 'cadvisorjenkinsbot', 'cf-buildpacks-eng', 'changelogbot', 'ci', 'claude', 'cloudbees-pull-request-builder', 'clrbuilder', 'codelingobot', 'codex', 'codspeedbot', 'containersshbuilder', 'coreosbot', 'covbot', 'coveralls', 'cubic-dev-ai', 'cvp-ops', 'damn good b0t', 'devolutionsbot', 'devstats-sync', 'dosu', 'ericwittbot', 'fermybot', 'fluxcdbot', 'fossabot', 'gemini-code-assist', 'getporterbot', 'gitcoinbot', 'github-cncf-landscape-notifs', 'github-harold_pins', 'gocursor', 'goodluckbot', 'googlebot', 'gopherbot', 'goreleaserbot', 'gprasath', 'grafanabot', 'greptileai', 'grpc-kokoro', 'heptibot', 'hubot', 'infraq', 'intellij-rainbow-brackets', 'invalid-email-address', 'iptecharch-builder', 'issuehuntbot', 'jenkinsadmin', 'jfrogbot', 'jreleaserbot', 'jsdelivrbot', 'k3aibot', 'kaipilotbot', 'katacontainersbot', 'kernelprbot', 'krkn-chaos', 'kuasar-io-dev', 'kubescapebot', 'l5io', 'letsusegerrit', 'litmusbot', 'maxio', 'megaeasebot', 'megaeasex', 'mentatbot', 'modular-magician', 'monkeycode-ai', 'msftclas', 'msftgits', 'nsmbot', 'oai-codex', 'oceanjxbot', 'opencontrail-ci-admin', 'openebs-pro-sa', 'openfeaturebot', 'openssl-machine', 'opentelemetrybot', 'oss-sentinel-ai', 'oss-taishan-ai', 'otcbot', 'ovsrobot', 'pckgrbot', 'persesbot', 'pikbot', 'podmanbot', 'poiana', 'pouchrobot', 'projectstacker', 'prowbot', 'rancherbot', 'repobirdbot', 'rktbot', 'securitylab-codeanalysis', 'sizebot', 'sourcery-ai', 'spellarbot', 'spinframeworkbot', 'spinnakerbot', 'spinnakerbot2', 'stacklokbot', 'startxfr', 'stateful-wombot', 'streamnativebot', 'thelinuxfoundation', 'thinkbotbot', 'ti-srebot', 'titanium-octobot', 'travisbuddy', 'tremorbot', 'twbs-grunt', 'unownbot', 'vmwghbot', 'vsxen', 'waxobot', 'weaveworksbot', 'web-flow', 'weblate', 'wingetbot', 'yahoocla', 'zephyr-github', 'zephyrbot', 'actions%', 'claassistant%', 'cncf-bot%', 'codecov%', 'coderabbit%', 'copilot%', 'dependabot%', 'github %', 'github-action%', 'imgbot%', 'jenkins-%', 'k8s-%', 'mergify%', 'qodo-%', 'snyk%', 'strimzi%', 'svc%', 'travis%bot', 'prom%bot', 'promptless%', '%-bot', '%-robot', '%bot-%', '%[%bot]%', '%ci%bot', '%cla%bot%', '%autobot', '%buildbot%', '%copybara%', '%renovate%', '%envoy-filter-example%', '%automat%', '%agent', '%-ci', '%-gerrit', '%-infra', '%-jenkins', '%-release', '%-service%', '%-team%', '%-testing', '% bot', '% ci', '% team', '% releaser', '%machine account%'])
) sub
where
  sub.country_id != ''
group by
  sub.country_id
;
