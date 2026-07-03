-- Bounded rebuild of gha_issues_pull_requests for a backfill window [from, to)  (PHASE 2).
--
-- Companion to postprocess_issues_prs.sql (unchanged hourly max(id) script). We rebuild by the set of PRs
-- "touched" in the window (by event-time dup_created_at), NOT by pr.created_at: a PR created before the
-- window can be backfilled inside it, and its issue<->PR link must still be refreshed. The touched set is:
-- PRs whose own dup_created_at is in the window, plus PRs matched (number, repo) to issues whose
-- dup_created_at is in the window. We delete the links for those PR ids and re-insert them.
-- gha_issues_pull_requests has no unique key -> delete-then-insert; idempotent.
--
-- Window from session settings devstats.postprocess_from / devstats.postprocess_to. Unset => safe no-op.
-- Simplest full alternative: truncate gha_issues_pull_requests + run structure (see runbook).

with pp as (
  select
    nullif(current_setting('devstats.postprocess_from', true), '')::timestamp as pfrom,
    nullif(current_setting('devstats.postprocess_to', true), '')::timestamp as pto
), touched_prs as (
  select distinct pr.id as pull_request_id
  from gha_pull_requests pr, pp
  where pr.dup_created_at >= pp.pfrom and pr.dup_created_at < pp.pto
  union
  select distinct pr.id as pull_request_id
  from gha_pull_requests pr
  join gha_issues i on i.number = pr.number and i.dup_repo_id = pr.dup_repo_id
  cross join pp
  where i.dup_created_at >= pp.pfrom and i.dup_created_at < pp.pto
)
delete from gha_issues_pull_requests gipr
using touched_prs tp
where gipr.pull_request_id = tp.pull_request_id
;

with pp as (
  select
    nullif(current_setting('devstats.postprocess_from', true), '')::timestamp as pfrom,
    nullif(current_setting('devstats.postprocess_to', true), '')::timestamp as pto
), touched_prs as (
  select distinct pr.id as pull_request_id
  from gha_pull_requests pr, pp
  where pr.dup_created_at >= pp.pfrom and pr.dup_created_at < pp.pto
  union
  select distinct pr.id as pull_request_id
  from gha_pull_requests pr
  join gha_issues i on i.number = pr.number and i.dup_repo_id = pr.dup_repo_id
  cross join pp
  where i.dup_created_at >= pp.pfrom and i.dup_created_at < pp.pto
)
insert into gha_issues_pull_requests(
  issue_id, pull_request_id, number, repo_id, repo_name, created_at
)
select distinct
  i.id, pr.id, i.number, i.dup_repo_id, i.dup_repo_name, pr.created_at
from gha_issues i
join gha_pull_requests pr on i.number = pr.number and i.dup_repo_id = pr.dup_repo_id
join touched_prs tp on tp.pull_request_id = pr.id
;
