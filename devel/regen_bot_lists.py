#!/usr/bin/env python3
"""Propagate the bot-exclusion list from util_sql/exclude_bots.sql to every copy of it.

Edit ONLY `util_sql/exclude_bots.sql` (single line: `not like all(array['a', 'b%', ...])`),
then run `./devel/regen_bot_lists.py` from the devstats repo root. It rewrites:

  util_sql/only_bots.sql                  like any(array[...])
  util_sql/exclude_bots_table_insert.sql  unnest(array[...])  (fills gha_bot_logins)
  structure.sql                           COPY public.gha_bot_logins block
  util_sql/*.sql                          every literal array[...] containing 'googlebot'
  ../devstats-reports/sql/*.sql           same (if that repo is checked out next to this one)
  ../devstatscode/rust/compat/fixtures/   verbatim copies used by the Rust compat tests (if present)

Patterns are matched with `lower(login) not like all(array[...])`, so they must be lower case;
`%` is a wildcard, `_` matches exactly one character. See BOTS.md.
"""
import glob
import os
import re
import shutil
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REPORTS = os.path.join(os.path.dirname(ROOT), "devstats-reports")
FIXTURES = os.path.join(os.path.dirname(ROOT), "devstatscode", "rust", "compat", "fixtures")

ARRAY_RE = re.compile(r"array\[((?:\s*'[^']*'\s*,?)+)\]", re.S)
MASTER = os.path.join(ROOT, "util_sql", "exclude_bots.sql")

master = open(MASTER).read()
m = ARRAY_RE.search(master)
if not m or not master.startswith("not like all(array["):
    sys.exit("%s: expected a single `not like all(array[...])` expression" % MASTER)
pats = re.findall(r"'([^']*)'", m.group(1))
dups = set(p for p in pats if pats.count(p) > 1)
if dups:
    sys.exit("duplicate patterns: %s" % sorted(dups))
bad = [p for p in pats if p != p.lower()]
if bad:
    sys.exit("patterns must be lower case: %s" % bad)
array = "array[" + ", ".join("'%s'" % p for p in pats) + "]"


def write(path, content):
    if open(path).read() != content:
        open(path, "w").write(content)
        print("updated  ", os.path.relpath(path, ROOT))


def replace_arrays(path):
    src = open(path).read()
    n = 0

    def repl(mm):
        nonlocal n
        if "'googlebot'" not in mm.group(1):
            return mm.group(0)
        n += 1
        return array

    out = ARRAY_RE.sub(repl, src)
    if n:
        write(path, out)
    return n


write(os.path.join(ROOT, "util_sql", "exclude_bots.sql"), "not like all(%s)\n" % array)
write(os.path.join(ROOT, "util_sql", "only_bots.sql"), "like any(%s)\n" % array)
replace_arrays(os.path.join(ROOT, "util_sql", "exclude_bots_table_insert.sql"))

sp = os.path.join(ROOT, "structure.sql")
lines = open(sp).read().split("\n")
start = lines.index("COPY public.gha_bot_logins (pattern) FROM stdin;")
end = lines.index("\\.", start)
lines[start + 1:end] = pats
write(sp, "\n".join(lines))

files = glob.glob(os.path.join(ROOT, "util_sql", "*.sql"))
if os.path.isdir(REPORTS):
    files += glob.glob(os.path.join(REPORTS, "sql", "*.sql"))
skip = {"exclude_bots.sql", "only_bots.sql", "exclude_bots_table_insert.sql"}
total = sum(replace_arrays(f) for f in sorted(files) if os.path.basename(f) not in skip)
print("literal arrays replaced:", total)

if os.path.isdir(FIXTURES):
    copies = {
        "util_sql/exclude_bots.sql": [
            "tags/data/util_sql/exclude_bots.sql",
            "website_data/util_sql/exclude_bots.sql",
            "runq/data/util_sql/exclude_bots.sql",
            "calc_metric/exclude_bots.sql",
        ],
        "util_sql/exclude_bots_table_insert.sql": ["structure/util_sql/exclude_bots_table_insert.sql"],
        "util_sql/actors.sql": ["runq/data/util_sql/actors.sql"],
    }
    for src, dsts in copies.items():
        for d in dsts:
            dst = os.path.join(FIXTURES, d)
            if os.path.exists(dst) and open(os.path.join(ROOT, src)).read() != open(dst).read():
                shutil.copyfile(os.path.join(ROOT, src), dst)
                print("synced   ", os.path.relpath(dst, ROOT))
print("%d patterns" % len(pats))
