# dotpy — Python Utility Scripts

This directory contains small Python helper scripts used by developers and AI
coding agents working in this repository.  All scripts require only the Python
standard library (no `pip install` needed) and are invoked directly with
`python3`.

---

## Scripts

### `calc_widths.py` — Markdown table column-width calculator

Reads a Markdown file (or stdin) and, for every table found, prints the maximum
between-pipe cell width for each column and a correctly sized separator row.

**Usage**

```shell
python3 dotpy/calc_widths.py <file.md>
python3 dotpy/calc_widths.py          # reads from stdin
```

**Example output**

```
Table at line 23 — 3 col(s), between-pipe widths: 33  8  11
Separator: |---------------------------------|--------|-----------|
```

**When to use**

- When authoring a new Markdown table: draft the rows first, run this script,
  then paste in the printed separator and pad every cell to the reported widths.
- When a table has grown (new rows with wider content): re-run to get updated
  widths and separator, then widen existing cells accordingly.

---

### `check_tables.py` — Markdown table column-width validator

Reads a Markdown file (or stdin) and checks that every row in every table —
header, separator, and data rows — has the same between-pipe column widths.
Reports any mismatches with file name and line number.

**Usage**

```shell
python3 dotpy/check_tables.py <file.md>
python3 dotpy/check_tables.py          # reads from stdin
```

**Exit codes:** `0` = all tables pass, `1` = one or more errors found.

**Example output (error)**

```
ERROR: README.md:67 col 3: width mismatch (header=32, this row=28)
  Row: '| http://localhost:8080/server | backend | Server API |'
```

**When to use**

- After editing any Markdown table, run to confirm nothing is misaligned.
- In CI or pre-commit hooks to catch formatting regressions automatically.

---

## Conventions for adding new scripts

When a new Python utility is useful enough to save for future use, add it here:

1. Place the `.py` file in this `dotpy/` directory.
2. Add a `#!/usr/bin/env python3` shebang and a module-level docstring that
   includes a **Usage** section and a brief description of what the script does.
3. Accept a file path as the first positional argument (and fall back to stdin)
   so the script is composable with pipes.
4. Add an entry to this README under the **Scripts** section following the same
   format: script name, one-line description, Usage block, example output, and
   a "When to use" note.
5. Reference the script from `AGENTS.md` if coding agents should know about it.

