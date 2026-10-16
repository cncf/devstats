select
  a.login as actor,
  e.actor_id,
  count(distinct e.id) as cnt
from
  gha_actors a,
  gha_events e
left join
  gha_actors_affiliations af
on
  e.actor_id = af.actor_id
  and af.dt_from <= e.created_at
  and af.dt_to > e.created_at
  and af.company_name != ''
where
  a.id = e.actor_id
  and lower(a.login) not like all(array['alighrobot', 'amplabjenkins', 'angular-builds', 'appveyorbot', 'architectbot', 'asfgit', 'athenabot', 'atlantisbot', 'auto', 'blackduck-serv-builder', 'blueorangutan', 'bosh-ci-push-pull', 'buildhive', 'cadvisorjenkinsbot', 'cf-buildpacks-eng', 'changelogbot', 'ci', 'claude', 'cloudbees-pull-request-builder', 'clrbuilder', 'codelingobot', 'codex', 'codspeedbot', 'containersshbuilder', 'coreosbot', 'covbot', 'coveralls', 'cubic-dev-ai', 'cvp-ops', 'damn good b0t', 'devolutionsbot', 'devstats-sync', 'dosu', 'ericwittbot', 'fermybot', 'fluxcdbot', 'fossabot', 'gemini-code-assist', 'getporterbot', 'gitcoinbot', 'github-cncf-landscape-notifs', 'github-harold_pins', 'gocursor', 'goodluckbot', 'googlebot', 'gopherbot', 'goreleaserbot', 'gprasath', 'grafanabot', 'greptileai', 'grpc-kokoro', 'heptibot', 'hubot', 'infraq', 'intellij-rainbow-brackets', 'invalid-email-address', 'iptecharch-builder', 'issuehuntbot', 'jenkinsadmin', 'jfrogbot', 'jreleaserbot', 'jsdelivrbot', 'k3aibot', 'kaipilotbot', 'katacontainersbot', 'kernelprbot', 'krkn-chaos', 'kuasar-io-dev', 'kubescapebot', 'l5io', 'letsusegerrit', 'litmusbot', 'maxio', 'megaeasebot', 'megaeasex', 'mentatbot', 'modular-magician', 'monkeycode-ai', 'msftclas', 'msftgits', 'nsmbot', 'oai-codex', 'oceanjxbot', 'opencontrail-ci-admin', 'openebs-pro-sa', 'openfeaturebot', 'openssl-machine', 'opentelemetrybot', 'oss-sentinel-ai', 'oss-taishan-ai', 'otcbot', 'ovsrobot', 'pckgrbot', 'persesbot', 'pikbot', 'podmanbot', 'poiana', 'pouchrobot', 'projectstacker', 'prowbot', 'rancherbot', 'repobirdbot', 'rktbot', 'securitylab-codeanalysis', 'sizebot', 'sourcery-ai', 'spellarbot', 'spinframeworkbot', 'spinnakerbot', 'spinnakerbot2', 'stacklokbot', 'startxfr', 'stateful-wombot', 'streamnativebot', 'thelinuxfoundation', 'thinkbotbot', 'ti-srebot', 'titanium-octobot', 'travisbuddy', 'tremorbot', 'twbs-grunt', 'unownbot', 'vmwghbot', 'vsxen', 'waxobot', 'weaveworksbot', 'web-flow', 'weblate', 'wingetbot', 'yahoocla', 'zephyr-github', 'zephyrbot', 'actions%', 'claassistant%', 'cncf-bot%', 'codecov%', 'coderabbit%', 'copilot%', 'dependabot%', 'github %', 'github-action%', 'imgbot%', 'jenkins-%', 'k8s-%', 'mergify%', 'qodo-%', 'snyk%', 'strimzi%', 'svc%', 'travis%bot', 'prom%bot', 'promptless%', '%-bot', '%-robot', '%bot-%', '%[%bot]%', '%ci%bot', '%cla%bot%', '%autobot', '%buildbot%', '%copybara%', '%renovate%', '%envoy-filter-example%', '%automat%', '%agent', '%-ci', '%-gerrit', '%-infra', '%-jenkins', '%-release', '%-service%', '%-team%', '%-testing', '% bot', '% ci', '% team', '% releaser', '%machine account%'])
  and e.type in (
    'PullRequestReviewCommentEvent', 'PushEvent', 'PullRequestEvent',
    'IssuesEvent', 'IssueCommentEvent', 'CommitCommentEvent', 'PullRequestReviewEvent'
  )
  and af.actor_id is null
  and e.created_at >= now() - '{{ago}}'::interval
group by
  a.login,
  e.actor_id
order by
  cnt desc
limit
  {{lim}}
;
