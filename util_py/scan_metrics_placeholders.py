#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

PERIOD_RE = re.compile(r"\{\{period:[^}]+\}\}")
FROM_RE   = re.compile(r"\{\{from\}\}")
TO_RE     = re.compile(r"\{\{to\}\}")

MACROS = ("{{from}}", "{{to}}")


@dataclass(frozen=True)
class Hit:
    macro: str
    line: int
    col: int
    line_text: str


def find_unquoted_macros(sql: str, macros: Iterable[str] = MACROS) -> list[Hit]:
    """
    Return occurrences of macros that are NOT inside:
      - single-quoted strings
      - dollar-quoted strings ($$...$$ or $tag$...$tag$)
      - line comments (-- ...)
      - block comments (/* ... */), supports nesting
    """
    macros = tuple(macros)
    hits: list[Hit] = []

    lines = sql.splitlines()

    in_sq = False                 # single-quoted string
    in_line_comment = False
    block_comment_depth = 0       # nested /* ... */
    dollar_tag: str | None = None # None or tag string ("" for $$)

    i = 0
    n = len(sql)
    line = 1
    col = 1

    def startswith_at(s: str) -> bool:
        return sql.startswith(s, i)

    def current_line_text() -> str:
        if 1 <= line <= len(lines):
            return lines[line - 1]
        return ""

    while i < n:
        ch = sql[i]

        # Newline
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

        # Inside nested block comment
        if block_comment_depth > 0:
            if startswith_at("/*"):
                block_comment_depth += 1
                i += 2
                col += 2
                continue
            if startswith_at("*/"):
                block_comment_depth -= 1
                i += 2
                col += 2
                continue
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
                # SQL escapes ' as '' inside strings
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

        # Not in any comment/string: detect comment starts
        if startswith_at("--"):
            in_line_comment = True
            i += 2
            col += 2
            continue
        if startswith_at("/*"):
            block_comment_depth = 1
            i += 2
            col += 2
            continue

        # Dollar-quote start: $tag$ or $$
        if ch == "$":
            j = sql.find("$", i + 1)
            if j != -1:
                tag = sql[i + 1 : j]  # may be empty for $$
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

        # Macro hits (unquoted region)
        matched = False
        for m in macros:
            if sql.startswith(m, i):
                hits.append(Hit(macro=m, line=line, col=col, line_text=current_line_text().rstrip("\n")))
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

    # Task 1: files with {{period:*}} AND {{from}} AND {{to}}
    both_period_and_from_to: list[Path] = []

    # Task 2: files with any unquoted {{from}}/{{to}} (regardless of {{period:*}})
    unquoted_from_to: list[tuple[Path, list[Hit]]] = []

    for p in sql_files:
        try:
            text = p.read_text(encoding="utf-8", errors="replace")
        except Exception as e:
            print(f"SKIP: {p} ({e})", file=sys.stderr)
            continue

        has_period = PERIOD_RE.search(text) is not None
        has_from = FROM_RE.search(text) is not None
        has_to = TO_RE.search(text) is not None

        if has_period and has_from and has_to:
            both_period_and_from_to.append(p)

        hits = find_unquoted_macros(text, MACROS)
        if hits:
            unquoted_from_to.append((p, hits))

    # Output
    print("=== Task 1: Files containing {{period:*}} AND {{from}} AND {{to}} ===")
    print(f"Count: {len(both_period_and_from_to)}")
    for p in both_period_and_from_to:
        print(p)
    print()

    print("=== Task 2: Files containing UNQUOTED {{from}} and/or {{to}} (independent of {{period:*}}) ===")
    print(f"Count: {len(unquoted_from_to)}")
    for p, hits in unquoted_from_to:
        print(p)
        for h in hits:
            # show line/col + the line text for quick inspection
            print(f"  {h.macro} at L{h.line}:{h.col}: {h.line_text}")
        print()

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
