update preferences set team_id = 0;
select * from preferences;

insert or ignore into 
  permission(id, role_id, action, scope, created, updated)
select
  (id * 10000) + 1, 1, 'dashboards:read', 'dashboards:uid:' || uid, datetime(), datetime()
from
  dashboard
where
  is_folder = 0
;
