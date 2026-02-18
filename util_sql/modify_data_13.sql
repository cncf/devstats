select distinct inserted_at from gha_commits order by 1;
update gha_commits set inserted_at = null where inserted_at = (select distinct inserted_at from gha_commits order by 1 limit 1);
