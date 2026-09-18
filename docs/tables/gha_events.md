# `gha_events` table

- This is the main GHA (GitHub archives) table. It represents single event.
- Each GHA JSON contains single GitHub event, and singe GHA hour archive file and a bunch (about 80k) JSONS (events) that happened this hour (I mean events on all GitHup repos, not only Kubernetes).
- This table holds all GitHub events. Other tables defined as [variable](https://github.com/cncf/devstats/blob/master/docs/tables/variable_table.md) have `event_id` as a part of their primary key.
- This is a const table, values are inserted once and doesn't change, see [const table](https://github.com/cncf/devstats/blob/master/docs/tables/const_table.md).
- Events are created during standard GitHub archives import from JSON [here (pre-2015 format)](https://github.com/cncf/devstats/blob/master/cmd/gha2db/gha2db.go#L791-L809) or [here (current format)](https://github.com/cncf/devstats/blob/master/cmd/gha2db/gha2db.go#L1056-L1074).
- Old (pre-20150 GitHub events have no ID, it is generated artificially [here](https://github.com/cncf/devstats/blob/master/cmd/gha2db/gha2db.go#L1355), old format ID are < 0.
- For details about pre-2015 and current format check [analysis](https://github.com/cncf/devstats/tree/master/analysis), per-2015 data is prefixed with `old_`, current format is prefixed with `new_`. Example old and new JSONs [here](https://github.com/cncf/devstats/tree/master/jsons).
- It contains about 1.8M records as of Feb 2018.
- It is created here: [structure.go](https://github.com/cncf/devstats/blob/master/structure.go#L23-L40).
- You can see its SQL structure here: [structure.sql](https://github.com/cncf/devstats/blob/master/structure.sql#L205-L216).
- Its primary key is `id`.
- Values from this table are often duplicated in other tables (to speedup processing) as `dup_type`, `dup_created_at`.
- [ghaapi2db](https://github.com/cncf/devstats/tree/master/cmd/ghapi2db/ghapi2db.go) tool is creating events of type `ArtificialEvent` when it detects that some issue/PR has wrong labels set or wrong milestone.
- It happens when somebody changes label and/or milestone without commenting on the issue, or after commenting. Change label/milestone is not creating any GitHub event, so the final issue/PR state can be wrong.
- Each GitHub event have single (1:1) entry in [gha_payloads](https://github.com/cncf/devstats/blob/master/docs/tables/gha_payloads.md) table.

# Columns

- `id`: GitHub event ID. Since the native event id band epoch (`NativeIDBandRules` in devstatscode `eventid.go` / `rust/devstatscode/src/eventid.rs`) events are stored as `GitHub id + band * 10^12`: band 1 for the issue/PR/comment/review/fork/star/release/... sequence, band 2 for the parallel `PushEvent`/`CreateEvent`/`DeleteEvent` sequence (GitHub restarted its id sequence on 2025-10-09, so raw ids would collide with 2016-2025 events), `id / 10^12` is the band and `id % 10^12` the GitHub id; earlier events keep the raw id. All bands are below `2^48`; ids `>= 2^48` are artificial (ghapi2db, restores, sync) and negative ids are old-format (pre-2015) hashes or restored orphan commits.
- `type`: GitHub event type, can be: PullRequestReviewEvent, PullRequestReviewCommentEvent, MemberEvent, PushEvent, ReleaseEvent, CreateEvent, GollumEvent, TeamAddEvent, DeleteEvent, PublicEvent, ForkEvent, PullRequestEvent, IssuesEvent, WatchEvent, IssueCommentEvent, CommitCommentEvent.
- `actor_id`: GitHub actor ID (actor who created this event).
- `repo_id`: GitHub repository ID.
- `public`: Is this event public? Always `true` because private events are not gathered by GHA (GitHub Archives).
- `created_at`: Event creation date.
- `org_id`: GitHub organization ID. Can be null.
- `forkee_id`: This is a old repository ID (for per-2015 events, for current format it is null).
- `dup_actor_login`: Duplicated GitHub actor login (from [gha_actors](https://github.com/cncf/devstats/blob/master/docs/tables/gha_actors.md) table).
- `dup_repo_name`: Duplicated GitHub repository name (note that repository name can change in time, but repository ID remains the same, see [gha_repos](https://github.com/cncf/devstats/blob/master/docs/tables/gha_repos.md) table).
