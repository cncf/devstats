#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from dataclasses import dataclass
from pathlib import Path

PERIOD_RE = re.compile(r"\{\{period:[^}]+\}\}")
FROM_RE = re.compile(r"\{\{from\}\}")
TO_RE = re.compile(r"\{\{to\}\}")

MACROS = ("{{from}}", "{{to}}")


@dataclass
class Hit:
    macro: str
    line: int
    col: int


def scan_unquoted_hits(sql: str) -> list[Hit]:
    """
    Find occurrences of {{from}} / {{to}} that are NOT inside:
      - single-quoted strings
      - dollar-quoted strings ($$...$$ or $tag$...$tag$)
      - line comments (-- ...)
      - block comments (/* ... */)

    This approximates "unquoted" in the way you care about for SQL parsing.
    """
    hits: list[Hit] = []

    in_sq = False              # single-quoted string
    in_line_comment = False
    in_block_comment = False
    dollar_tag: str | None = None  # None or tag string ("" for $$)

    i = 0
    line = 1
    col = 1
    n = len(sql)

    def startswith_at(s: str) -> bool:
        return sql.startswith(s, i)

    while i < n:
        ch = sql[i]

        # Newline handling
        if ch == "\n":
            line += 1
            col = 1
            in_line_comment = False
            i += 1
            continue

        # Inside line comment
        if in_line_comment:
            i += 1
            col += 1
            continue

        # Inside block comment
        if in_block_comment:
            if startswith_at("*/"):
                in_block_comment = False
                i += 2
                col += 2
            else:
                i += 1
                col += 1
            continue

        # Inside dollar-quoted string
        if dollar_tag is not None:
            end_delim = f"${dollar_tag}$"
            if sql.startswith(end_delim, i):
                i += len(end_delim)
                col += len(end_delim)
                dollar_tag = None
            else:
                i += 1
                col += 1
            continue

        # Inside single-quoted string
        if in_sq:
            if ch == "'":
                # SQL escapes single quote as ''
                if i + 1 < n and sql[i + 1] == "'":
                    i += 2
                    col += 2
                else:
                    in_sq = False
                    i += 1
                    col += 1
            else:
                i += 1
                col += 1
            continue

        # Not in any string/comment: detect comment starts
        if startswith_at("--"):
            in_line_comment = True
            i += 2
            col += 2
            continue
        if startswith_at("/*"):
            in_block_comment = True
            i += 2
            col += 2
            continue

        # Dollar-quote start: $tag$ or $$
        if ch == "$":
            j = sql.find("$", i + 1)
            if j != -1:
                tag = sql[i + 1 : j]  # may be empty for $$
                # Conservative validation of tag
                if tag == "" or re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", tag):
                    dollar_tag = tag
                    delim_len = (j - i) + 1
                    i += delim_len
                    col += delim_len
                    continue

        # Single-quote start
        if ch == "'":
            in_sq = True
            i += 1
            col += 1
            continue

        # Unquoted macro hits
        matched = False
        for m in MACROS:
            if sql.startswith(m, i):
                hits.append(Hit(macro=m, line=line, col=col))
                i += len(m)
                col += len(m)
                matched = True
                break
        if matched:
            continue

        i += 1
        col += 1

    return hits


def main() -> int:
    root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("metrics")
    if not root.exists():
        print(f"ERROR: path not found: {root}", file=sys.stderr)
        return 2

    sql_files = sorted(root.rglob("*.sql"))

    flagged = 0
    candidates = 0

    for p in sql_files:
        try:
            text = p.read_text(encoding="utf-8", errors="replace")
        except Exception as e:
            print(f"SKIP: {p} ({e})", file=sys.stderr)
            continue

        # Must contain at least one {{period:...}} and both {{from}} and {{to}}
        if not PERIOD_RE.search(text):
            continue
        if not (FROM_RE.search(text) and TO_RE.search(text)):
            continue

        candidates += 1

        hits = scan_unquoted_hits(text)
        # keep only from/to hits (function already does, but be explicit)
        hits = [h for h in hits if h.macro in MACROS]

        if not hits:
            continue

        flagged += 1
        lines = text.splitlines()

        print(str(p))
        for h in hits:
            # Show the line content for context
            line_txt = lines[h.line - 1] if 0 <= h.line - 1 < len(lines) else ""
            print(f"  {h.macro} unquoted at L{h.line}:{h.col}: {line_txt.rstrip()}")
        print()

    print(f"Candidates (contain {{period:*}} + {{from}} + {{to}}): {candidates}", file=sys.stderr)
    print(f"Flagged (have unquoted {{from}}/{{to}}): {flagged}", file=sys.stderr)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
