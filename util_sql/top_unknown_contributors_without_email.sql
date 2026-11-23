with topu as (
  select e.actor_id,
    e.dup_actor_login as login
  from
    gha_events e
  left join
    gha_actors_affiliations aa
  on
    e.actor_id = aa.actor_id
  where
    e.type in (
      'CommitCommentEvent', 'IssueCommentEvent', 'IssuesEvent', 'PullRequestReviewEvent', 
      'PullRequestEvent', 'PullRequestReviewCommentEvent', 'PushEvent'
    )
    and lower(e.dup_actor_login) not like all(array['adjudicator', 'airanthembot', 'alighrobot', 'amplabjenkins', 'angular-builds', 'appveyorbot', 'architectbot', 'asfgit', 'athenabot', 'atlantisbot', 'auto', 'aws-pca-k8s-plugin-ops-admin', 'blackduck-serv-builder', 'blueorangutan', 'bosh-ci-push-pull', 'breken-ai', 'buildhive', 'cadvisorjenkinsbot', 'cclaude', 'cf-buildpacks-eng', 'changelogbot', 'ci', 'ci-maintainer', 'claude', 'cloudbees-pull-request-builder', 'clrbuilder', 'codelingobot', 'codex', 'codspeedbot', 'containersshbuilder', 'coreosbot', 'covbot', 'coveralls', 'cubic-dev-ai', 'cvp-ops', 'damn good b0t', 'devolutionsbot', 'devstats-sync', 'dosu', 'engineering-harness', 'ericwittbot', 'eti-jarvis', 'fermybot', 'fluxcdbot', 'fossabot', 'gemini-code-assist', 'getporterbot', 'gitcoinbot', 'github', 'github-cncf-landscape-notifs', 'github-harold_pins', 'github-runner-solo', 'gocursor', 'goodluckbot', 'googlebot', 'gopherbot', 'goreleaserbot', 'gprasath', 'grafanabot', 'greptileai', 'grpc-kokoro', 'guide', 'hackmd-deploy', 'heptibot', 'hive-architect', 'hive-quality', 'hive-sec-check', 'hive-strategist', 'hubot', 'infraq', 'intellij-rainbow-brackets', 'invalid-email-address', 'iptecharch-builder', 'issuehuntbot', 'jenkinsadmin', 'jfrogbot', 'jreleaserbot', 'jsdelivrbot', 'k3aibot', 'kaipilotbot', 'katacontainersbot', 'kernelprbot', 'krkn-chaos', 'kuadrant-dev', 'kuasar-io-dev', 'kubescapebot', 'l5io', 'letsusegerrit', 'litmusbot', 'maxio', 'megaeasebot', 'megaeasex', 'mentatbot', 'modular-magician', 'monkeycode-ai', 'msftclas', 'msftgits', 'nsmbot', 'oadp-maintainers', 'oai-codex', 'oceanjxbot', 'openai', 'opencontrail-ci-admin', 'openebs-pro-sa', 'openfeaturebot', 'openssl-machine', 'opentelemetrybot', 'operations', 'oss-maintainer', 'oss-sentinel-ai', 'oss-taishan-ai', 'otcbot', 'outreach', 'ovsrobot', 'pckgrbot', 'persesbot', 'pikbot', 'podmanbot', 'poiana', 'postgres-versions-updater', 'pouchrobot', 'projectstacker', 'prowbot', 'public-cloud-k8s-versions-check', 'quality', 'rancherbot', 'repobirdbot', 'rktbot', 'scanner', 'sec-check', 'securitylab-codeanalysis', 'shentubot', 'sizebot', 'sourcery-ai', 'spectobot', 'spectopo', 'spellarbot', 'spinframeworkbot', 'spinnakerbot', 'spinnakerbot2', 'stacklokbot', 'startxfr', 'stateful-wombot', 'strategist', 'streamnativebot', 'telemetry', 'thelinuxfoundation', 'thinkbotbot', 'ti-srebot', 'titanium-octobot', 'travisbuddy', 'tremorbot', 'twbs-grunt', 'unownbot', 'vmwghbot', 'vr-architect', 'vsxen', 'waxobot', 'weaveworksbot', 'web-flow', 'weblate', 'winget-releases-tessl', 'wingetbot', 'yahoocla', 'zephyr-github', 'zephyrbot', 'actions%', 'claassistant%', 'cncf-bot%', 'codecov%', 'coderabbit%', 'copilot%', 'dependabot%', 'github %', 'github-action%', 'imgbot%', 'jenkins-%', 'k8s-%', 'mergify%', 'qodo-%', 'snyk%', 'strimzi%', 'svc%', 'travis%bot', 'prom%bot', 'promptless%', '%-bot', '%-robot', '%bot-%', '%[%bot]%', '%ci%bot', '%cla%bot%', '%autobot', '%buildbot%', '%copybara%', '%renovate%', '%envoy-filter-example%', '%automat%', '%agent', '%-ci', '%-gerrit', '%-infra', '%-jenkins', '%-release', '%-service%', '%-team%', '%-testing', '% bot', '% ci', '% team', '% releaser', '%machine account%'])
    and aa.actor_id is null
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
  e.dup_actor_login as actor,
  count(distinct e.id) as cnt
from
  top t,
  gha_events e
left join
  gha_actors_emails ae
on
  e.actor_id = ae.actor_id
where
  t.actor_id = e.actor_id
  and e.type in (
      'CommitCommentEvent', 'IssueCommentEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'PullRequestEvent', 'PullRequestReviewCommentEvent', 'PushEvent'
    )
  and (ae.email is null or ae.email like '%users.noreply.github.com')
group by
  actor
order by
  cnt desc
limit
  20
;
