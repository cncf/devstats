-- temp_buffers must be set before the session touches any temp table,
-- calc_metric reuses sessions across ranges, so ignore the error then
do $$ begin
  begin
    set temp_buffers = '1GB';
  exception when others then
    null;
  end;
end $$;

-- evaluate the ~100 like patterns of exclude_bots once per distinct commit
-- login instead of 6 times per commit row
create temp table pcc_ok_logins_{{rnd}} as
select login
from (
  select distinct lower(dup_actor_login) as login from gha_commits
  where dup_created_at >= '{{from}}' and dup_created_at < '{{to}}'
  union select distinct lower(dup_author_login) from gha_commits
  where dup_created_at >= '{{from}}' and dup_created_at < '{{to}}' and author_id is not null
  union select distinct lower(dup_committer_login) from gha_commits
  where dup_created_at >= '{{from}}' and dup_created_at < '{{to}}' and committer_id is not null
) sub
where
  login is not null
  and (login {{exclude_bots}})
;
create index on pcc_ok_logins_{{rnd}}(login);
analyze pcc_ok_logins_{{rnd}};

-- evaluate exclude_bots once per actor with a known country instead of
-- once per aggregated commit row
create temp table pcc_actors_{{rnd}} as
select
  id as actor_id,
  country_name
from
  gha_actors
where
  country_name is not null
  and country_name != ''
  and (lower(login) {{exclude_bots}})
;
create index on pcc_actors_{{rnd}}(actor_id);
analyze pcc_actors_{{rnd}};

create temp table pcc_commits_{{rnd}} as
select r.repo_group as repo_group,
  c.sha,
  c.dup_actor_id as actor_id,
  c.author_id,
  c.committer_id,
  (lower(c.dup_actor_login) in (select login from pcc_ok_logins_{{rnd}})) as f_actor,
  (lower(c.dup_author_login) in (select login from pcc_ok_logins_{{rnd}})) as f_author,
  (lower(c.dup_committer_login) in (select login from pcc_ok_logins_{{rnd}})) as f_committer
from
  gha_repo_groups r,
  gha_commits c
where
  c.dup_repo_id = r.id
  and c.dup_repo_name = r.name
  and c.dup_created_at >= '{{from}}'
  and c.dup_created_at < '{{to}}'
  and (
    (lower(c.dup_actor_login) in (select login from pcc_ok_logins_{{rnd}}))
    or (c.author_id is not null and (lower(c.dup_author_login) in (select login from pcc_ok_logins_{{rnd}})))
    or (c.committer_id is not null and (lower(c.dup_committer_login) in (select login from pcc_ok_logins_{{rnd}})))
  );
analyze pcc_commits_{{rnd}};
with commits_data as (
  select repo_group,
    sha,
    actor_id
  from
    pcc_commits_{{rnd}}
  where
    f_actor
  union select repo_group,
    sha,
    author_id as actor_id
  from
    pcc_commits_{{rnd}}
  where
    author_id is not null
    and f_author
  union select repo_group,
    sha,
    committer_id as actor_id
  from
    pcc_commits_{{rnd}}
  where
    committer_id is not null
    and f_committer
), data as (
  select 'prjcntr' as type,
    a.country_name,
    c.repo_group,
    hll_add_agg(hll_hash_bigint(c.actor_id)) as rcommitters,
    hll_add_agg(hll_hash_text(c.sha)) as rcommits
  from
    commits_data c,
    pcc_actors_{{rnd}} a
  where
    a.actor_id = c.actor_id
  group by
    a.country_name,
    c.repo_group
)
select
  concat(inn.type, ';', inn.repo_group, '`', inn.country_name, ';rcommitters,rcommits') as name,
  inn.rcommitters,
  inn.rcommits
from
  data inn
where
  inn.repo_group is not null 
order by
  name
;
drop table pcc_commits_{{rnd}};
drop table pcc_actors_{{rnd}};
drop table pcc_ok_logins_{{rnd}};
