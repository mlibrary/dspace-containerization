#!/usr/bin/env python3
"""
check_tables.py — Validate Markdown table column-width consistency.

Usage:
    python3 dotpy/check_tables.py <file.md>
    python3 dotpy/check_tables.py          # reads from stdin

Checks that every row in every Markdown table — header, separator, and all
data rows — has the same between-pipe column widths.  Any mismatch is reported
with the file name and 1-based line number so it can be located immediately.

Exit codes:
    0 — all tables are consistently formatted
    1 — one or more column-width mismatches were found

Typical workflow
----------------
1. After editing a Markdown table, run:
       python3 dotpy/check_tables.py README.md
2. If errors are reported, run calc_widths.py on the same file to get the
   correct separator row and content widths, then fix the table:
       python3 dotpy/calc_widths.py README.md
"""

import sys


def check_tables(lines, filename='<stdin>'):
    """
    Validate column-width consistency for every table in *lines* (list[str]).

    Returns a list of human-readable error strings.  An empty list means all
    tables pass.  Each error includes *filename* and the 1-based line number.
    """
    in_table = False
    col_widths = []
    errors = []

    for i, line in enumerate(lines, 1):
        stripped = line.rstrip('\n')
        is_row = stripped.startswith('|') and stripped.endswith('|')

        if is_row:
            parts = stripped.split('|')[1:-1]
            widths = [len(p) for p in parts]

            if not in_table:
                in_table = True
                col_widths = widths
            else:
                if len(widths) != len(col_widths):
                    errors.append(
                        f'{filename}:{i}: column count changed '
                        f'(header had {len(col_widths)}, this row has {len(widths)})'
                    )
                else:
                    for j, (expected, actual) in enumerate(zip(col_widths, widths)):
                        if expected != actual:
                            errors.append(
                                f'{filename}:{i} col {j + 1}: '
                                f'width mismatch (header={expected}, this row={actual})'
                            )
                            errors.append(f'  Row: {repr(stripped)}')
        else:
            in_table = False
            col_widths = []

    return errors


def main():
    if len(sys.argv) > 1:
        path = sys.argv[1]
        with open(path) as f:
            lines = f.readlines()
        filename = path
    else:
        lines = sys.stdin.readlines()
        filename = '<stdin>'

    errors = check_tables(lines, filename)

    if errors:
        for e in errors:
            print('ERROR:', e)
        sys.exit(1)
    else:
        print('All tables OK')
        sys.exit(0)


if __name__ == '__main__':
    main()
