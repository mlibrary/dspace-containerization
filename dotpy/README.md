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

### `gen_delta.py` — Regenerate `backend/config/DELTA.md` from the live cfg files

Parses the three gitignored `from-kube.*.dspace.cfg` files in `backend/config/`,
compares every property across all three environments, and writes a fresh
`DELTA.md` containing a summary table of differing properties, auto-generated
key findings, and recommendations.  Sensitive values (`db.password`,
`identifier.doi.password`, `api.user.key`, etc.) are redacted in the output
so `DELTA.md` is safe to commit.

**Usage**

```shell
# Auto-discovers backend/config/ and writes backend/config/DELTA.md:
python3 dotpy/gen_delta.py

# Explicit directory:
python3 dotpy/gen_delta.py backend/config/

# Explicit directory and output file:
python3 dotpy/gen_delta.py backend/config/ backend/config/DELTA.md

# Write to stdout instead of a file:
python3 dotpy/gen_delta.py backend/config/ -
```

**Prerequisites**

The three `from-kube.*.dspace.cfg` files must exist locally (they are
gitignored).  Fetch them from the cluster first:

```shell
for NS in production workshop demo; do
  kubectl -n $NS get secret dspace-cfg \
    -o jsonpath="{.data.dspace\.cfg}" | base64 --decode \
    > backend/config/from-kube.${NS}.dspace.cfg
done
```

**Example output (stderr)**

```
Parsed backend/config/from-kube.demo.dspace.cfg (254 properties)
Parsed backend/config/from-kube.production.dspace.cfg (262 properties)
Parsed backend/config/from-kube.workshop.dspace.cfg (259 properties)
Written to backend/config/DELTA.md
```

**When to use**

- After fetching fresh cfg files from the cluster to update the diff.
- After making a change to a `dspace-cfg` secret to document what changed.
- To bootstrap `DELTA.md` from a blank slate.

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

