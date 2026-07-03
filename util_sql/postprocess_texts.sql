-- Watermarks are keyed off the SAME event_id ranges the INSERT below gates
-- (real: <2^48+1, artificial: [2^48+1, 329900000000000), sync: >=329900000000000),
-- NOT off `type`. This prevents a row whose type does not match its id-range from
-- poisoning a watermark - a '%Event'-typed id>=2^48 row can inflate the
-- real-event watermark (opt=0) and silently skip ALL new real-event texts.
with var as (
  select
    coalesce(max(event_id), -9223372036854775808) as max_event_id,
    0 as opt
  from
    gha_texts
  where
    event_id < 281474976710657
  union select coalesce(max(event_id), 281474976710657) as max_event_id,
    1 as opt
  from
    gha_texts
  where
    event_id >= 281474976710657
    and event_id < 329900000000000
  union select coalesce(max(event_id), 329900000000000) as max_event_id,
    2 as opt
  from
    gha_texts
  where
    event_id >= 329900000000000
)
insert into gha_texts(
  event_id, body, created_at, repo_id, repo_name, actor_id, actor_login, type
) 
select
  event_id, body, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_comments 
where
  body != ''
  and (
    (
      event_id > (
        select max_event_id from var where opt = 0
      )
      and event_id < 281474976710657
    )
    or (
      event_id > (
        select max_event_id from var where opt = 1
      )
      and event_id >= 281474976710657
      and event_id < 329900000000000
    )
    or (
      event_id > (
        select max_event_id from var where opt = 2
      )
      and event_id >= 329900000000000
    )
  )
union select
  event_id, message, dup_created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_commits
where
  message != ''
  and (
    (
      event_id > (
        select max_event_id from var where opt = 0
      )
      and event_id < 281474976710657
    )
    or (
      event_id > (
        select max_event_id from var where opt = 1
      )
      and event_id >= 281474976710657
      and event_id < 329900000000000
    )
    or (
      event_id > (
        select max_event_id from var where opt = 2
      )
      and event_id >= 329900000000000
    )
  )
union select
  event_id, title, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_issues
where
  title != ''
  and (
    (
      event_id > (
        select max_event_id from var where opt = 0
      )
      and event_id < 281474976710657
    )
    or (
      event_id > (
        select max_event_id from var where opt = 1
      )
      and event_id >= 281474976710657
      and event_id < 329900000000000
    )
    or (
      event_id > (
        select max_event_id from var where opt = 2
      )
      and event_id >= 329900000000000
    )
  )
union select
  event_id, body, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_issues
where
  body != ''
  and (
    (
      event_id > (
        select max_event_id from var where opt = 0
      )
      and event_id < 281474976710657
    )
    or (
      event_id > (
        select max_event_id from var where opt = 1
      )
      and event_id >= 281474976710657
      and event_id < 329900000000000
    )
    or (
      event_id > (
        select max_event_id from var where opt = 2
      )
      and event_id >= 329900000000000
    )
  )
union select 
  event_id, title, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_pull_requests
where
  title != ''
  and (
    (
      event_id > (
        select max_event_id from var where opt = 0
      )
      and event_id < 281474976710657
    )
    or (
      event_id > (
        select max_event_id from var where opt = 1
      )
      and event_id >= 281474976710657
      and event_id < 329900000000000
    )
    or (
      event_id > (
        select max_event_id from var where opt = 2
      )
      and event_id >= 329900000000000
    )
  )
union select
  event_id, body, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_pull_requests
where
  body != ''
  and (
    (
      event_id > (
        select max_event_id from var where opt = 0
      )
      and event_id < 281474976710657
    )
    or (
      event_id > (
        select max_event_id from var where opt = 1
      )
      and event_id >= 281474976710657
      and event_id < 329900000000000
    )
    or (
      event_id > (
        select max_event_id from var where opt = 2
      )
      and event_id >= 329900000000000
    )
  )
union select
  event_id, body, submitted_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_reviews
where
  body != ''
  and (
    (
      event_id > (
        select max_event_id from var where opt = 0
      )
      and event_id < 281474976710657
    )
    or (
      event_id > (
        select max_event_id from var where opt = 1
      )
      and event_id >= 281474976710657
      and event_id < 329900000000000
    )
    or (
      event_id > (
        select max_event_id from var where opt = 2
      )
      and event_id >= 329900000000000
    )
  )
;
