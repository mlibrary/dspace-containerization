#!/usr/bin/env python3
"""
format_table.py — Auto-format Markdown tables in place.

Usage:
    python3 dotpy/format_table.py <file.md>   # formats in place, prints summary
    python3 dotpy/format_table.py             # reads from stdin, writes to stdout

Algorithm
---------
For every Markdown table found:
1. Strip leading/trailing whitespace from each cell's content.
2. Calculate the maximum content width for each column (minimum 3 so the
   separator row always has at least three dashes).
3. Pad every data/header cell with one leading space and trailing spaces so
   all cells in a column are the same width.
4. Regenerate the separator row to the correct width, preserving any
   alignment markers ( : ) for left-explicit / right / center alignment.

Limitations
-----------
Cells containing a literal pipe character ( | ) will be mis-parsed because
the parser splits on all pipes.  Escape such cells as \\| before running.

Exit codes:
    0 — success (or no tables found)
    1 — error reading/writing the file
"""

from __future__ import annotations

import sys
from pathlib import Path


# ── helpers ───────────────────────────────────────────────────────────────────

def is_table_row(line: str) -> bool:
    s = line.rstrip('\n').strip()
    return s.startswith('|') and s.endswith('|')


def parse_cells(line: str) -> list[str]:
    """Split a table row into raw between-pipe strings (spaces preserved)."""
    return line.rstrip('\n').split('|')[1:-1]


def is_separator_row(cells: list[str]) -> bool:
    """Return True when every cell looks like a separator (dashes / colons only)."""
    for c in cells:
        s = c.strip()
        if not s:
            return False
        inner = s.replace(':', '', 2)   # remove at most two colons
        if not inner or not all(ch == '-' for ch in inner):
            return False
    return True


def detect_alignment(cell: str) -> str:
    """Infer column alignment from a raw separator cell."""
    s = cell.strip()
    if s.startswith(':') and s.endswith(':'):
        return 'center'
    if s.endswith(':'):
        return 'right'
    if s.startswith(':'):
        return 'left_explicit'
    return 'left'


def render_sep_cell(bp_width: int, align: str) -> str:
    """
    Render a separator cell occupying *bp_width* between-pipe characters,
    preserving *align* markers.

    bp_width = max_content_width + 2  (one space margin on each side)
    """
    if align == 'center':
        return ':' + '-' * (bp_width - 2) + ':'
    if align == 'right':
        return '-' * (bp_width - 1) + ':'
    if align == 'left_explicit':
        return ':' + '-' * (bp_width - 1)
    return '-' * bp_width          # default / left


def render_data_cell(content: str, bp_width: int) -> str:
    """
    Render a header or data cell occupying *bp_width* between-pipe characters.

    Result: ' ' + content.ljust(bp_width - 2) + ' '
    """
    return ' ' + content.ljust(bp_width - 2) + ' '


# ── core ──────────────────────────────────────────────────────────────────────

def format_tables(lines: list[str]) -> tuple[list[str], int]:
    """
    Scan *lines* for Markdown table blocks and return (new_lines, n_formatted).

    Each table block is replaced with a correctly padded version.
    Blocks whose rows have inconsistent column counts are passed through unchanged.
    """
    result: list[str] = []
    i = 0
    tables_formatted = 0

    while i < len(lines):
        if not is_table_row(lines[i]):
            result.append(lines[i])
            i += 1
            continue

        # ── collect the contiguous table block ──────────────────────────────
        block: list[str] = []
        while i < len(lines) and is_table_row(lines[i]):
            block.append(lines[i])
            i += 1

        # ── parse rows ──────────────────────────────────────────────────────
        sep_idx: int | None = None
        alignments: list[str] = []
        parsed: list[list[str]] = []   # stripped content (except sep row)

        for row_idx, raw in enumerate(block):
            cells = parse_cells(raw)
            if sep_idx is None and row_idx > 0 and is_separator_row(cells):
                sep_idx = row_idx
                alignments = [detect_alignment(c) for c in cells]
                parsed.append(cells)   # placeholder; will not be used for widths
            else:
                parsed.append([c.strip() for c in cells])

        # ── validate column count consistency ────────────────────────────────
        col_counts = {len(r) for r in parsed}
        if len(col_counts) != 1:
            result.extend(block)       # pass through unchanged
            continue

        ncols = len(parsed[0])
        if not alignments:
            alignments = ['left'] * ncols
        while len(alignments) < ncols:
            alignments.append('left')

        # ── compute max content width per column ─────────────────────────────
        # Separator rows are excluded; minimum is 3 so `---` is always valid.
        max_content = [3] * ncols
        for row_idx, row in enumerate(parsed):
            if row_idx == sep_idx:
                continue
            for col_idx, cell in enumerate(row):
                if col_idx < ncols:
                    max_content[col_idx] = max(max_content[col_idx], len(cell))

        # ── render ───────────────────────────────────────────────────────────
        for row_idx, raw in enumerate(block):
            eol = '\r\n' if raw.endswith('\r\n') else '\n' if raw.endswith('\n') else ''
            bp = [w + 2 for w in max_content]   # between-pipe width per column

            if row_idx == sep_idx:
                cells_out = [render_sep_cell(bp[c], alignments[c]) for c in range(ncols)]
            else:
                cells_out = [render_data_cell(parsed[row_idx][c], bp[c]) for c in range(ncols)]

            result.append('|' + '|'.join(cells_out) + '|' + eol)

        tables_formatted += 1

    return result, tables_formatted


# ── entry point ───────────────────────────────────────────────────────────────

def main() -> None:
    if len(sys.argv) > 1:
        path = Path(sys.argv[1])
        try:
            text = path.read_text(encoding='utf-8')
        except OSError as e:
            print(f'ERROR: {e}', file=sys.stderr)
            sys.exit(1)

        lines = text.splitlines(keepends=True)
        new_lines, count = format_tables(lines)

        if count == 0:
            print(f'No tables found in {path}')
            return

        path.write_text(''.join(new_lines), encoding='utf-8')
        print(f'Formatted {count} table(s) in {path}')
    else:
        lines = sys.stdin.readlines()
        new_lines, _ = format_tables(lines)
        sys.stdout.write(''.join(new_lines))


if __name__ == '__main__':
    main()

