create index comment_substring_approval_re on gha_comments(substring(body from '(?i)(?:^|\n|\r)\s*/(approve|lgtm)\s*(?:\n|\r|$)'));
