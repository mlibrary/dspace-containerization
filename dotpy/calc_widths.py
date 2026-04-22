#!/usr/bin/env python3
"""
calc_widths.py — Compute Markdown table column widths and generate separator rows.

Usage:
    python3 dotpy/calc_widths.py <file.md>
    python3 dotpy/calc_widths.py          # reads from stdin

For every table found in the Markdown file, prints:
  - The line number where the table header begins
  - The maximum between-pipe cell width for each column
  - The correctly sized separator row, ready to paste into the source

Background — how Markdown table cells are measured
---------------------------------------------------
A well-formatted Markdown table cell looks like:

    | content_padded_to_W |

where W is the widest content in that column and there is exactly one space
margin on each side.  The "between-pipe width" of the cell is therefore W + 2.

The separator row must use the same between-pipe width as the data/header rows:

    |----(W+2 dashes)----|

calc_widths.py measures the actual between-pipe width of every cell across all
rows (including any existing separator row) and reports the maximum per column.
Use that maximum as the target width when padding cells, and paste the printed
separator row directly into the table.

Typical workflow
----------------
1. Draft a table in your Markdown file without worrying about alignment.
2. Run:  python3 dotpy/calc_widths.py my_doc.md
3. Copy the printed separator row into the table.
4. Pad every cell in each column to the matching width.
5. Validate:  python3 dotpy/check_tables.py my_doc.md
"""

import sys


def compute_table_widths(lines):
    """
    Walk *lines* (list[str]) and return one entry per table found.

    Returns: list of (start_lineno: int, col_widths: list[int])
        start_lineno  — 1-based line number of the table header row
        col_widths[i] — maximum between-pipe character count for column i,
                        across all rows (header, separator, and data rows)
    """
    results = []
    in_table = False
    table_start = 0
    col_max = []

    for i, line in enumerate(lines, 1):
        stripped = line.rstrip('\n')
        is_row = stripped.startswith('|') and stripped.endswith('|')

        if is_row:
            parts = stripped.split('|')[1:-1]
            widths = [len(p) for p in parts]

            if not in_table:
                in_table = True
                table_start = i
                col_max = list(widths)
            else:
                for j, w in enumerate(widths):
                    if j < len(col_max):
                        col_max[j] = max(col_max[j], w)
                    else:
                        col_max.append(w)
        else:
            if in_table:
                results.append((table_start, list(col_max)))
            in_table = False
            col_max = []

    if in_table:
        results.append((table_start, list(col_max)))

    return results


def main():
    if len(sys.argv) > 1:
        path = sys.argv[1]
        with open(path) as f:
            lines = f.readlines()
        label = path
    else:
        lines = sys.stdin.readlines()
        label = '<stdin>'

    tables = compute_table_widths(lines)

    if not tables:
        print(f'No tables found in {label}')
        return

    for start, widths in tables:
        separator = '|' + '|'.join('-' * w for w in widths) + '|'
        width_str = '  '.join(str(w) for w in widths)
        print(f'Table at line {start} — {len(widths)} col(s), between-pipe widths: {width_str}')
        print(f'Separator: {separator}')
        print()


if __name__ == '__main__':
    main()
