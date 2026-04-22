# Agent Rules

> **Read this file at the start of every new agent session, before taking any action.**
> These rules apply to all AI coding agents (GitHub Copilot, Claude, Cursor, etc.) working in this repository.

## File Access

- **Stay within the project directory**: Only read, write, or search files that are under the project root directory. Do not access files outside the project directory unless the developer **explicitly** requests it.
  - When a developer does request access to an outside file, read **only that specific file** — do not browse, list, or search the surrounding directory or any parent directories.
  - Never speculatively explore paths outside the project root.

## Command-Line Tool Usage

- **Disable interactive paging**: When running commands that may invoke a pager (e.g., `git`, `less`, `man`, `kubectl`, etc.), always suppress paging so the command returns immediately and its output is captured. For example:
  - Use `git --no-pager <command>` for git commands.
  - Append `| cat` to commands that might page output (e.g., `kubectl ... | cat`).
  - Set `GIT_PAGER=cat` or `PAGER=cat` in the environment when needed.
  - Never rely on interactive input; all commands must run non-interactively and return their full output.

## Task Tracking (TODO.md / DONE.md)

- **TODO.md** is the active task list, maintained by the agent. Organise work as **tasks** with **subtasks**:
  ```
  ## Task Title
  Short description of the overall goal.

  - [ ] Subtask one
  - [ ] Subtask two
  - [ ] Verify the current state of the project achieves the task goal
  - [ ] Verify with the developer that the task is complete
  ```
- **Check off subtasks** (`- [x]`) as they are completed. Keep the task in `TODO.md` until **all** subtasks — including the final developer-verification step — are checked off.
- **Every task must end with a developer-verification subtask** as its final item:
  `- [ ] Verify with the developer that the task is complete`
  When this subtask is reached, ask the developer: *"Are there any additional subtasks needed before this task is complete?"* Add any new subtasks before the verification step, then check them off before archiving.
- **Only when all subtasks are done**, move the whole task to `DONE.md`:
  1. **Remove** the task block from `TODO.md`.
  2. **Prepend** it to `DONE.md` (insert after the `# DONE` heading, before any existing entries) with a timestamp and a brief summary. This keeps `DONE.md` in **reverse chronological order** (newest entry first).
- Example entry in `DONE.md`:
  ```
  ## 2026-04-21T14:32:00 — Added AGENTS.md paging rule
  Added the first rule to AGENTS.md requiring all CLI commands to suppress
  interactive paging so output is captured without waiting for user input.
  ```
- Never leave a completed task in `TODO.md`; always archive it to `DONE.md`.

## Python Utility Scripts (`dotpy/`)

- **Use existing scripts** in `dotpy/` before writing ad-hoc Python one-liners. See [`dotpy/README.md`](dotpy/README.md) for the full list and usage instructions.
- **Save reusable scripts** to `dotpy/` rather than running them once and discarding them:
  - Add a `#!/usr/bin/env python3` shebang and a module-level docstring with a **Usage** section.
  - Accept a file path as the first positional argument and fall back to stdin.
  - Add an entry to `dotpy/README.md` following the existing format.

## Pull Request Summaries

- **When the developer asks for a PR summary**, write it to `pr-summary.md` in
  the project root and open the file so they can select-all and copy from the
  editor. `pr-summary.md` is listed in `.gitignore` and will never be
  accidentally committed.
- Use standard GitHub-flavoured Markdown: `##` / `###` headings, `**bold**`,
  inline backticks, and bullet lists. Do not use HTML tags.
- Structure the summary as:
  1. **`## <Title>`** — one-line description matching the branch purpose.
  2. **`### Summary`** — 2–4 sentences on what the PR does and why.
  3. **`### Changes`** — one bold entry per changed file or directory with
     bullet sub-points explaining what changed.
  4. **`### Notes`** *(optional)* — follow-up items, known limitations, or
     things the reviewer should verify manually.
- Delete `pr-summary.md` after the PR is created; do not commit it.

## Markdown Formatting

- **Format tables correctly**: Every column in a Markdown table must be padded so that all cells in that column (header, separator, and every data row) are the same width. The separator row must use dashes (`-`) at least as wide as the widest cell in each column. Mismatched widths cause IDE warnings ("Table is not correctly formatted").
  - Determine the widest cell in each column (considering the rendered source text, not the display text of links).
  - Pad every shorter cell with trailing spaces to match that width.
  - Use the same number of dashes in the separator row as the column width.
  - **The data rows — not just the header — define the required column width.** The header and separator must be padded/extended to match the widest data cell, not the other way around.
  - To auto-format a table (strip whitespace, recalculate all widths, pad in place), run: `python3 dotpy/format_table.py <file.md>` — rewrites the file with every table correctly padded. **Use this first.**
  - To compute the exact separator without editing, run: `python3 dotpy/calc_widths.py <file.md>` — it prints the maximum between-pipe width per column and the ready-to-paste separator row for every table in the file.
  - To validate alignment after editing, run: `python3 dotpy/check_tables.py <file.md>` — exits `0` if all tables are consistent, `1` with error details if not.
  - If a table requires very long lines (e.g., > 120 characters per row), prefer using a shorter link display text or a bullet-list format instead of a wide table.

