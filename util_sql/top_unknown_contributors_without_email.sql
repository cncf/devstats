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
    and lower(e.dup_actor_login) not like all(array['alighrobot', 'angular-builds', 'appveyorbot', 'architectbot', 'asfgit', 'athenabot', 'atlantisbot', 'auto', 'blueorangutan', 'bosh-ci-push-pull', 'cadvisorjenkinsbot', 'cf-buildpacks-eng', 'changelogbot', 'claude', 'clrbuilder', 'codex', 'containersshbuilder', 'coreosbot', 'covbot', 'coveralls', 'cubic-dev-ai', 'devolutionsbot', 'devstats-sync', 'dosu', 'fermybot', 'fluxcdbot', 'fossabot', 'gemini-code-assist', 'getporterbot', 'gitcoinbot', 'github-cncf-landscape-notifs', 'github-harold_pins', 'goodluckbot', 'googlebot', 'goreleaserbot', 'gprasath', 'greptileai', 'infraq', 'invalid-email-address', 'kaipilotbot', 'katacontainersbot', 'kernelprbot', 'kuasar-io-dev', 'kubescapebot', 'litmusbot', 'megaeasex', 'nsmbot', 'openebs-pro-sa', 'openfeaturebot', 'openssl-machine', 'opencontrail-ci-admin', 'opentelemetrybot', 'ovsrobot', 'pckgrbot', 'pikbot', 'podmanbot', 'poiana', 'pouchrobot', 'prowbot', 'rktbot', 'securitylab-codeanalysis', 'sizebot', 'sourcery-ai', 'spinframeworkbot', 'spinnakerbot', 'startxfr', 'stateful-wombot', 'streamnativebot', 'thelinuxfoundation', 'thinkbotbot', 'ti-srebot', 'titanium-octobot', 'travisbuddy', 'tremorbot', 'unownbot', 'web-flow', 'weblate', 'wingetbot', 'zephyr-github', 'zephyrbot', 'actions%', 'claassistant%', 'cncf-bot%', 'codecov%', 'coderabbit%', 'copilot%', 'dependabot%', 'github %', 'github-action%', 'imgbot%', 'jenkins-%', 'k8s-%', 'mergify%', 'qodo-%', 'snyk%', 'strimzi%', 'svc%', 'travis%bot', 'prom%bot', '%-bot', '%-robot', '%bot-%', '%[%bot]%', '%ci%bot', '%cla%bot%', '%autobot', '%buildbot%', '%copybara%', '%renovate%', '%envoy-filter-example%', '%automat%', '%agent', '%-ci', '%-gerrit', '%-infra', '%-jenkins', '%-release', '%-service%', '%-team%', '%-testing', '% bot', '% ci', '% team'])
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
