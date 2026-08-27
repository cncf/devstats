-- Targeted rebuild of gha_issues_pull_requests for an exact set of restored event ids (PHASE 2b).
--
-- Companion to postprocess_issues_prs_range.sql (window variant); driven by the pp_event_ids temp
-- table (see postprocess_texts_ids.sql for the contract). The touched set is: PRs whose own event_id
-- is in the set, plus PRs matched (number, repo) to issues whose event_id is in the set - then their
-- issue<->PR links are deleted and re-inserted (no unique key -> delete-then-insert; idempotent).
-- Restores of comments/reviews/commits never insert gha_issues/gha_pull_requests rows, so for the
-- automatic post-restore run this is a cheap no-op; it only does work if a caller ever passes event
-- ids of issue/PR events.

with touched_prs as (
  select distinct pr.id as pull_request_id
  from gha_pull_requests pr
  where pr.event_id in (select event_id from pp_event_ids)
  union
  select distinct pr.id as pull_request_id
  from gha_pull_requests pr
  join gha_issues i on i.number = pr.number and i.dup_repo_id = pr.dup_repo_id
  where i.event_id in (select event_id from pp_event_ids)
)
delete from gha_issues_pull_requests gipr
using touched_prs tp
where gipr.pull_request_id = tp.pull_request_id
;

with touched_prs as (
  select distinct pr.id as pull_request_id
  from gha_pull_requests pr
  where pr.event_id in (select event_id from pp_event_ids)
  union
  select distinct pr.id as pull_request_id
  from gha_pull_requests pr
  join gha_issues i on i.number = pr.number and i.dup_repo_id = pr.dup_repo_id
  where i.event_id in (select event_id from pp_event_ids)
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
