#!/usr/bin/env python3
"""Fix footnote markers in backend/bin/README.md: replace stripped superscripts with plain [N]."""
import re, sys

path = sys.argv[1] if len(sys.argv) > 1 else 'backend/bin/README.md'
text = open(path, encoding='utf-8').read()

# ----- Review-notes section headers -----
fixes = [
    # empty brackets followed by distinctive text
    (r'\[\] \*\*`meta_file` and `meta_file_orcid` placeholder', '[1] **`meta_file` and `meta_file_orcid` placeholder'),
    (r'\[\] \*\*`meta_file_orcid` field qualifier', '[2] **`meta_file_orcid` field qualifier'),
    (r'\[\] \*\*`find_crawlers` arguments', '[3] **`find_crawlers` arguments'),
    (r'\[4\] \*\*`prep-logs`', '[4] **`prep-logs`'),  # already correct if ⁴ survived
    (r'\[5\] \*\*`update_all_ip_table`', '[5] **`update_all_ip_table`'),
    (r'\[6\] \*\*`move-to-aptrust-regular`', '[6] **`move-to-aptrust-regular`'),
    (r'\[7\] \*\*`report-aptrust-status`', '[7] **`report-aptrust-status`'),
    (r'\[8\] \*\*`filter-media-cronjob`', '[8] **`filter-media-cronjob`'),
    (r'\[9\] \*\*`find-items-to-unrestrict-bio`', '[9] **`find-items-to-unrestrict-bio`'),
    (r'\[\] \*\*`find-items-to-unrestrict-rack`', '[10] **`find-items-to-unrestrict-rack`'),
    (r'\[\] \*\*`meta_file_author` and `meta_file_desc`', '[11] **`meta_file_author` and `meta_file_desc`'),
    (r'\(see \[\]\)', '(see [1])'),
    (r'\[\] \*\*`report-double-original`', '[12] **`report-double-original`'),
    (r'\[\] \*\*`report-embargo`', '[13] **`report-embargo`'),
    # Also normalise ⁴-⁹ that may remain as Unicode
    ('\u2074', '4'), ('\u2075', '5'), ('\u2076', '6'),
    ('\u2077', '7'), ('\u2078', '8'), ('\u2079', '9'),
    ('\u2070', '0'),  # ⁰ — used in [10] after ¹ was stripped
]

for old, new in fixes:
    text = re.sub(old, new, text)

# ----- In-table cell references -----
cell_fixes = [
    # find_crawlers: [3]
    (r'or `nslookup`\. \[\]', 'or `nslookup`. [3]'),
    # meta_file: [1]
    (r'`dc\.type` on items\. \[\]', '`dc.type` on items. [1]'),
    # meta_file_orcid: [1] [2]
    (r'via `itemupdate`\. \[\] \[\]', 'via `itemupdate`. [1] [2]'),
    # find-items-to-unrestrict-rack: [10]
    (r'database records\. \[0\]', 'database records. [10]'),
    # meta_file_author: [11]
    (r"(via `itemupdate`\. )\[\](\s*\|)", r'\g<1>[11]\2'),
    # meta_file_desc: [11]  (same pattern – second occurrence)
    (r"(via `itemupdate`\. )\[\](\s*\|)", r'\g<1>[11]\2'),
    # report-double-original: [12]
    (r'for manual review\. \[\]', 'for manual review. [12]'),
    # report-embargo: [13]
    (r'release dates\. \[\]', 'release dates. [13]'),
]

for old, new in cell_fixes:
    text = re.sub(old, new, text)

open(path, 'w', encoding='utf-8').write(text)
print("Done")

