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
  ../velocity/                           SQL partial, BigQuery bot predicates and Go author matcher

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
VELOCITY = os.path.join(os.path.dirname(ROOT), "velocity")

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


def write(path, content, original=None):
    current = open(path).read() if os.path.exists(path) else None
    if original is not None and current != original:
        sys.exit("%s changed during regeneration; retry with the current file" % path)
    if current != content:
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
        write(path, out, src)
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

if os.path.isdir(VELOCITY):
    regex = "(?s)^(?:" + "|".join(
        "".join(
            ".*" if c == "%" else "." if c == "_" else "\\" + c if c in r"\.^$|?*+()[]{}" else c
            for c in p
        )
        for p in pats
    ) + ")$"
    if "'" in regex or "`" in regex:
        sys.exit("bot patterns cannot contain quotes used by Velocity SQL/Go literals")
    write(os.path.join(VELOCITY, "sql", "exclude_bots.sql"), "not like all(%s)\n" % array)
    generated = re.compile(r"(?im)^([ \t]*)(AND )?NOT REGEXP_(?:CONTAINS|MATCH)\(LOWER\(actor\.login\), r'.*'\) -- devstats bots$")
    unsafe_filter = re.compile(r"(?im)^([ \t]*)(AND )?(?:LOWER\()?actor\.login\)? not like '%bot%'[ \t]*$")
    first_filter = re.compile(r"(?im)^([ \t]*)(?:and )?(?:lower\()?actor\.login\)? not like '[^']*'[ \t]*$")
    for path in sorted(glob.glob(os.path.join(VELOCITY, "BigQuery", "velocity_*.sql"))):
        src = open(path).read()
        function = "REGEXP_CONTAINS" if src.startswith("#standardSQL") else "REGEXP_MATCH"
        predicate = "NOT %s(LOWER(actor.login), r'%s') -- devstats bots" % (function, regex)
        if unsafe_filter.search(src):
            base = re.sub(generated.pattern + r"\n?", "", src)
            out = unsafe_filter.sub(lambda m: m[1] + (m[2] or "") + predicate, base)
        elif generated.search(src):
            out = generated.sub(lambda m: m[1] + (m[2] or "") + predicate, src)
        else:
            out = first_filter.sub(lambda m: m[0] + "\n" + m[1] + "AND " + predicate, src, count=1)
        write(path, out, src)
    path = os.path.join(VELOCITY, "tools", "enrich_authors", "main.go")
    if os.path.isfile(path):
        src = open(path).read()
        out, n = re.subn(
            r"(?m)^var devstatsBotRE = regexp\.MustCompile\(`[^`]*`\)$",
            lambda _: "var devstatsBotRE = regexp.MustCompile(`%s`)" % regex,
            src,
        )
        if n != 1:
            sys.exit("%s: expected one devstatsBotRE declaration" % path)
        write(path, out, src)
print("%d patterns" % len(pats))
