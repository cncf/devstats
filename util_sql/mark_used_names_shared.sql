UPDATE gha_actors_names an
SET origin = 1
WHERE an.origin = 0
  AND EXISTS (
    SELECT 1
    FROM gha_commits c
    WHERE c.author_name = an.name
  );
