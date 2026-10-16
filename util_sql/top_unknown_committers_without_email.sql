with topu as (
  select distinct sub.actor_id,
    sub.login
  from (
    select c.dup_actor_id as actor_id,
      c.dup_actor_login as login
    from
      gha_commits c
    left join
      gha_actors_affiliations aa
    on
      c.dup_actor_id = aa.actor_id
    where
      lower(c.dup_actor_login) not like all(array['alighrobot', 'amplabjenkins', 'angular-builds', 'appveyorbot', 'architectbot', 'asfgit', 'athenabot', 'atlantisbot', 'auto', 'blackduck-serv-builder', 'blueorangutan', 'bosh-ci-push-pull', 'buildhive', 'cadvisorjenkinsbot', 'cf-buildpacks-eng', 'changelogbot', 'ci', 'claude', 'cloudbees-pull-request-builder', 'clrbuilder', 'codelingobot', 'codex', 'codspeedbot', 'containersshbuilder', 'coreosbot', 'covbot', 'coveralls', 'cubic-dev-ai', 'cvp-ops', 'damn good b0t', 'devolutionsbot', 'devstats-sync', 'dosu', 'ericwittbot', 'fermybot', 'fluxcdbot', 'fossabot', 'gemini-code-assist', 'getporterbot', 'gitcoinbot', 'github-cncf-landscape-notifs', 'github-harold_pins', 'gocursor', 'goodluckbot', 'googlebot', 'gopherbot', 'goreleaserbot', 'gprasath', 'grafanabot', 'greptileai', 'grpc-kokoro', 'heptibot', 'hubot', 'infraq', 'intellij-rainbow-brackets', 'invalid-email-address', 'iptecharch-builder', 'issuehuntbot', 'jenkinsadmin', 'jfrogbot', 'jreleaserbot', 'jsdelivrbot', 'k3aibot', 'kaipilotbot', 'katacontainersbot', 'kernelprbot', 'krkn-chaos', 'kuasar-io-dev', 'kubescapebot', 'l5io', 'letsusegerrit', 'litmusbot', 'maxio', 'megaeasebot', 'megaeasex', 'mentatbot', 'modular-magician', 'monkeycode-ai', 'msftclas', 'msftgits', 'nsmbot', 'oai-codex', 'oceanjxbot', 'opencontrail-ci-admin', 'openebs-pro-sa', 'openfeaturebot', 'openssl-machine', 'opentelemetrybot', 'oss-sentinel-ai', 'oss-taishan-ai', 'otcbot', 'ovsrobot', 'pckgrbot', 'persesbot', 'pikbot', 'podmanbot', 'poiana', 'pouchrobot', 'projectstacker', 'prowbot', 'rancherbot', 'repobirdbot', 'rktbot', 'securitylab-codeanalysis', 'sizebot', 'sourcery-ai', 'spellarbot', 'spinframeworkbot', 'spinnakerbot', 'spinnakerbot2', 'stacklokbot', 'startxfr', 'stateful-wombot', 'streamnativebot', 'thelinuxfoundation', 'thinkbotbot', 'ti-srebot', 'titanium-octobot', 'travisbuddy', 'tremorbot', 'twbs-grunt', 'unownbot', 'vmwghbot', 'vsxen', 'waxobot', 'weaveworksbot', 'web-flow', 'weblate', 'wingetbot', 'yahoocla', 'zephyr-github', 'zephyrbot', 'actions%', 'claassistant%', 'cncf-bot%', 'codecov%', 'coderabbit%', 'copilot%', 'dependabot%', 'github %', 'github-action%', 'imgbot%', 'jenkins-%', 'k8s-%', 'mergify%', 'qodo-%', 'snyk%', 'strimzi%', 'svc%', 'travis%bot', 'prom%bot', 'promptless%', '%-bot', '%-robot', '%bot-%', '%[%bot]%', '%ci%bot', '%cla%bot%', '%autobot', '%buildbot%', '%copybara%', '%renovate%', '%envoy-filter-example%', '%automat%', '%agent', '%-ci', '%-gerrit', '%-infra', '%-jenkins', '%-release', '%-service%', '%-team%', '%-testing', '% bot', '% ci', '% team', '% releaser', '%machine account%'])
      and aa.actor_id is null
    union select c.author_id as actor_id,
      c.dup_author_login as login
    from
      gha_commits c
    left join
      gha_actors_affiliations aa
    on
      c.author_id = aa.actor_id
    where
      lower(c.dup_author_login) not like all(array['alighrobot', 'amplabjenkins', 'angular-builds', 'appveyorbot', 'architectbot', 'asfgit', 'athenabot', 'atlantisbot', 'auto', 'blackduck-serv-builder', 'blueorangutan', 'bosh-ci-push-pull', 'buildhive', 'cadvisorjenkinsbot', 'cf-buildpacks-eng', 'changelogbot', 'ci', 'claude', 'cloudbees-pull-request-builder', 'clrbuilder', 'codelingobot', 'codex', 'codspeedbot', 'containersshbuilder', 'coreosbot', 'covbot', 'coveralls', 'cubic-dev-ai', 'cvp-ops', 'damn good b0t', 'devolutionsbot', 'devstats-sync', 'dosu', 'ericwittbot', 'fermybot', 'fluxcdbot', 'fossabot', 'gemini-code-assist', 'getporterbot', 'gitcoinbot', 'github-cncf-landscape-notifs', 'github-harold_pins', 'gocursor', 'goodluckbot', 'googlebot', 'gopherbot', 'goreleaserbot', 'gprasath', 'grafanabot', 'greptileai', 'grpc-kokoro', 'heptibot', 'hubot', 'infraq', 'intellij-rainbow-brackets', 'invalid-email-address', 'iptecharch-builder', 'issuehuntbot', 'jenkinsadmin', 'jfrogbot', 'jreleaserbot', 'jsdelivrbot', 'k3aibot', 'kaipilotbot', 'katacontainersbot', 'kernelprbot', 'krkn-chaos', 'kuasar-io-dev', 'kubescapebot', 'l5io', 'letsusegerrit', 'litmusbot', 'maxio', 'megaeasebot', 'megaeasex', 'mentatbot', 'modular-magician', 'monkeycode-ai', 'msftclas', 'msftgits', 'nsmbot', 'oai-codex', 'oceanjxbot', 'opencontrail-ci-admin', 'openebs-pro-sa', 'openfeaturebot', 'openssl-machine', 'opentelemetrybot', 'oss-sentinel-ai', 'oss-taishan-ai', 'otcbot', 'ovsrobot', 'pckgrbot', 'persesbot', 'pikbot', 'podmanbot', 'poiana', 'pouchrobot', 'projectstacker', 'prowbot', 'rancherbot', 'repobirdbot', 'rktbot', 'securitylab-codeanalysis', 'sizebot', 'sourcery-ai', 'spellarbot', 'spinframeworkbot', 'spinnakerbot', 'spinnakerbot2', 'stacklokbot', 'startxfr', 'stateful-wombot', 'streamnativebot', 'thelinuxfoundation', 'thinkbotbot', 'ti-srebot', 'titanium-octobot', 'travisbuddy', 'tremorbot', 'twbs-grunt', 'unownbot', 'vmwghbot', 'vsxen', 'waxobot', 'weaveworksbot', 'web-flow', 'weblate', 'wingetbot', 'yahoocla', 'zephyr-github', 'zephyrbot', 'actions%', 'claassistant%', 'cncf-bot%', 'codecov%', 'coderabbit%', 'copilot%', 'dependabot%', 'github %', 'github-action%', 'imgbot%', 'jenkins-%', 'k8s-%', 'mergify%', 'qodo-%', 'snyk%', 'strimzi%', 'svc%', 'travis%bot', 'prom%bot', 'promptless%', '%-bot', '%-robot', '%bot-%', '%[%bot]%', '%ci%bot', '%cla%bot%', '%autobot', '%buildbot%', '%copybara%', '%renovate%', '%envoy-filter-example%', '%automat%', '%agent', '%-ci', '%-gerrit', '%-infra', '%-jenkins', '%-release', '%-service%', '%-team%', '%-testing', '% bot', '% ci', '% team', '% releaser', '%machine account%'])
      and aa.actor_id is null
    union select c.committer_id as actor_id,
      c.dup_committer_login as login
    from
      gha_commits c
    left join
      gha_actors_affiliations aa
    on
      c.committer_id = aa.actor_id
    where
      lower(c.dup_committer_login) not like all(array['alighrobot', 'amplabjenkins', 'angular-builds', 'appveyorbot', 'architectbot', 'asfgit', 'athenabot', 'atlantisbot', 'auto', 'blackduck-serv-builder', 'blueorangutan', 'bosh-ci-push-pull', 'buildhive', 'cadvisorjenkinsbot', 'cf-buildpacks-eng', 'changelogbot', 'ci', 'claude', 'cloudbees-pull-request-builder', 'clrbuilder', 'codelingobot', 'codex', 'codspeedbot', 'containersshbuilder', 'coreosbot', 'covbot', 'coveralls', 'cubic-dev-ai', 'cvp-ops', 'damn good b0t', 'devolutionsbot', 'devstats-sync', 'dosu', 'ericwittbot', 'fermybot', 'fluxcdbot', 'fossabot', 'gemini-code-assist', 'getporterbot', 'gitcoinbot', 'github-cncf-landscape-notifs', 'github-harold_pins', 'gocursor', 'goodluckbot', 'googlebot', 'gopherbot', 'goreleaserbot', 'gprasath', 'grafanabot', 'greptileai', 'grpc-kokoro', 'heptibot', 'hubot', 'infraq', 'intellij-rainbow-brackets', 'invalid-email-address', 'iptecharch-builder', 'issuehuntbot', 'jenkinsadmin', 'jfrogbot', 'jreleaserbot', 'jsdelivrbot', 'k3aibot', 'kaipilotbot', 'katacontainersbot', 'kernelprbot', 'krkn-chaos', 'kuasar-io-dev', 'kubescapebot', 'l5io', 'letsusegerrit', 'litmusbot', 'maxio', 'megaeasebot', 'megaeasex', 'mentatbot', 'modular-magician', 'monkeycode-ai', 'msftclas', 'msftgits', 'nsmbot', 'oai-codex', 'oceanjxbot', 'opencontrail-ci-admin', 'openebs-pro-sa', 'openfeaturebot', 'openssl-machine', 'opentelemetrybot', 'oss-sentinel-ai', 'oss-taishan-ai', 'otcbot', 'ovsrobot', 'pckgrbot', 'persesbot', 'pikbot', 'podmanbot', 'poiana', 'pouchrobot', 'projectstacker', 'prowbot', 'rancherbot', 'repobirdbot', 'rktbot', 'securitylab-codeanalysis', 'sizebot', 'sourcery-ai', 'spellarbot', 'spinframeworkbot', 'spinnakerbot', 'spinnakerbot2', 'stacklokbot', 'startxfr', 'stateful-wombot', 'streamnativebot', 'thelinuxfoundation', 'thinkbotbot', 'ti-srebot', 'titanium-octobot', 'travisbuddy', 'tremorbot', 'twbs-grunt', 'unownbot', 'vmwghbot', 'vsxen', 'waxobot', 'weaveworksbot', 'web-flow', 'weblate', 'wingetbot', 'yahoocla', 'zephyr-github', 'zephyrbot', 'actions%', 'claassistant%', 'cncf-bot%', 'codecov%', 'coderabbit%', 'copilot%', 'dependabot%', 'github %', 'github-action%', 'imgbot%', 'jenkins-%', 'k8s-%', 'mergify%', 'qodo-%', 'snyk%', 'strimzi%', 'svc%', 'travis%bot', 'prom%bot', 'promptless%', '%-bot', '%-robot', '%bot-%', '%[%bot]%', '%ci%bot', '%cla%bot%', '%autobot', '%buildbot%', '%copybara%', '%renovate%', '%envoy-filter-example%', '%automat%', '%agent', '%-ci', '%-gerrit', '%-infra', '%-jenkins', '%-release', '%-service%', '%-team%', '%-testing', '% bot', '% ci', '% team', '% releaser', '%machine account%'])
      and aa.actor_id is null
  ) sub
), others as (
  select distinct t.actor_id,
    a.id as other_actor_id,
    t.login
  from
    topu t,
    gha_actors a,
    gha_actors_affiliations aa
  where
    t.login = a.login
    and t.actor_id != a.id
    and a.id = aa.actor_id
), top as (
  select distinct t.actor_id,
    t.login
  from
    topu t
  left join
    others o
  on
    t.actor_id = o.actor_id
  where
    o.actor_id is null
)
select
  sub.actor,
  count(distinct sha) as cnt
from (
  select
    c.dup_actor_login as actor,
    c.sha
  from
    top t,
    gha_commits c
  left join
    gha_actors_emails ae
  on
    c.dup_actor_id = ae.actor_id
  where
    t.actor_id = c.dup_actor_id
    and (ae.email is null or ae.email like '%users.noreply.github.com')
  union select
    c.dup_author_login as actor,
    c.sha
  from
    top t,
    gha_commits c
  left join
    gha_actors_emails ae
  on
    c.author_id = ae.actor_id
  where
    t.actor_id = c.author_id
    and (ae.email is null or ae.email like '%users.noreply.github.com')
  union select
    c.dup_committer_login as actor,
    c.sha
  from
    top t,
    gha_commits c
  left join
    gha_actors_emails ae
  on
    c.committer_id = ae.actor_id
  where
    t.actor_id = c.committer_id
    and (ae.email is null or ae.email like '%users.noreply.github.com')
  ) sub
group by
  actor
order by
  cnt desc
limit
  20
;
