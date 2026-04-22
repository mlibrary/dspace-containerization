#!/usr/bin/env python3
"""
gen_delta.py — Compare the three environment dspace.cfg Kubernetes secrets
and regenerate DELTA.md from scratch.

Usage:
    python3 dotpy/gen_delta.py                        # auto-discovers backend/config/
    python3 dotpy/gen_delta.py <config_dir>           # explicit dir → <config_dir>/DELTA.md
    python3 dotpy/gen_delta.py <config_dir> <output>  # explicit dir and output file
    python3 dotpy/gen_delta.py <config_dir> -         # write to stdout

config_dir
    Directory containing the three from-kube.*.dspace.cfg files.
    Defaults to backend/config/ relative to the repository root.

output
    Where to write DELTA.md.  Defaults to <config_dir>/DELTA.md.
    Pass '-' to write to stdout instead.

Prerequisites
    The three input files must exist in config_dir:
        from-kube.demo.dspace.cfg
        from-kube.production.dspace.cfg
        from-kube.workshop.dspace.cfg

    Fetch them from the cluster first (see backend/config/README.md):
        kubectl -n <NS> get secret dspace-cfg \\
          -o jsonpath="{.data.dspace\\.cfg}" | base64 --decode > \\
          backend/config/from-kube.<NS>.dspace.cfg
"""

from __future__ import annotations

import sys
from datetime import datetime, timezone
from pathlib import Path


# ── constants ────────────────────────────────────────────────────────────────

ENVS = ['demo', 'production', 'workshop']

# Values for these keys are replaced with a placeholder in committed output
# because DELTA.md itself is version-controlled.
REDACTED_KEYS = {
    'db.password',
    'identifier.doi.password',
    'identifier.doi.password_working',
    'api.user.key',
}

# Cell values longer than this are truncated with '…' in the table
MAX_CELL = 58


# ── cfg parser ────────────────────────────────────────────────────────────────

def parse_cfg(path: Path) -> dict:
    """
    Parse a dspace.cfg (Java .properties style) file.

    Returns a dict mapping property name → value string.
    Handles:
      - '#' and blank line comments
      - 'key = value' and 'key=value' syntax
      - Multi-line values joined with '\\' line continuations
    """
    props: dict = {}
    key: str | None = None
    parts: list[str] = []

    def flush():
        nonlocal key, parts
        if key is not None:
            props[key] = ' '.join(parts).strip()
        key = None
        parts = []

    with open(path, encoding='utf-8', errors='replace') as fh:
        for raw in fh:
            line = raw.rstrip('\n')

            # If the previous line ended with \, this line continues that value.
            if parts and parts[-1].endswith('\\'):
                parts[-1] = parts[-1][:-1].rstrip()
                parts.append(line.strip())
                continue

            s = line.strip()
            if not s or s.startswith('#'):
                # A blank or comment line ends a simple (non-continuation) value
                # naturally; we let flush() happen on the next key= line.
                continue

            eq = line.find('=')
            if eq == -1:
                continue  # malformed line — skip

            flush()
            key = line[:eq].strip()
            parts = [line[eq + 1:].strip()]

    flush()
    return props


# ── formatting helpers ────────────────────────────────────────────────────────

def cell(key: str, val: str | None) -> str:
    """Return a display-safe, length-capped cell value for a property."""
    if val is None:
        return '*(absent)*'
    if key in REDACTED_KEYS:
        return '*(redacted)*'
    if not val:
        return '*(empty)*'
    return val if len(val) <= MAX_CELL else val[:MAX_CELL] + '…'


def md_table(headers: list[str], rows: list[list[str]]) -> str:
    """
    Render a properly padded Markdown table.

    Column widths are determined by the widest cell in each column (header
    or data).  Every cell is left-padded with one space and right-padded to
    the column width plus one trailing space.
    """
    widths = [len(h) for h in headers]
    for row in rows:
        for i, c in enumerate(row):
            widths[i] = max(widths[i], len(c))

    def fmt(cells: list[str]) -> str:
        return '|' + '|'.join(
            ' ' + c.ljust(widths[i]) + ' ' for i, c in enumerate(cells)
        ) + '|'

    sep = '|' + '|'.join('-' * (w + 2) for w in widths) + '|'
    return '\n'.join([fmt(headers), sep] + [fmt(r) for r in rows])


# ── delta generation ──────────────────────────────────────────────────────────

def generate(cfgs: dict[str, dict]) -> str:
    """
    Compare cfgs[env] dicts and return DELTA.md content as a string.
    cfgs keys must be exactly the three strings in ENVS.
    """
    # All property keys present in any environment
    all_keys: set[str] = set()
    for d in cfgs.values():
        all_keys.update(d.keys())

    # Partition into differing vs identical
    differing: list[str] = []
    identical: list[str] = []
    for k in sorted(all_keys):
        vals = {env: cfgs[env].get(k) for env in ENVS}
        unique = {v for v in vals.values() if v is not None}
        absent = [env for env in ENVS if k not in cfgs[env]]
        if len(unique) > 1 or absent:
            differing.append(k)
        else:
            identical.append(k)

    # ── Summary Table ────────────────────────────────────────────────────────
    headers = ['Property', 'demo', 'production', 'workshop']
    rows = []
    for k in differing:
        rows.append(
            ['`' + k + '`'] + [cell(k, cfgs[env].get(k)) for env in ENVS]
        )

    # ── Key Findings ─────────────────────────────────────────────────────────
    findings: list[tuple[str, str]] = []

    # 1. server/ui URLs
    server_vals = {env: cfgs[env].get('dspace.server.url', '') for env in ENVS}
    ui_vals = {env: cfgs[env].get('dspace.ui.url', '') for env in ENVS}
    if (
        all('localhost' in v for v in server_vals.values())
        and all('localhost' in v for v in ui_vals.values())
    ):
        findings.append((
            '`dspace.server.url` and `dspace.ui.url` are `localhost` in all three environments',
            'All three config files have:\n\n'
            '```\n'
            f'dspace.server.url = {server_vals["production"]}\n'
            f'dspace.ui.url     = {cfgs["production"].get("dspace.ui.url", "")}\n'
            '```\n\n'
            'This is **intentional**. These values are always overridden at pod startup '
            'by environment variables injected from the `backend-environment` ConfigMap '
            '(`dspace__P__server__P__url`, `dspace__P__ui__P__url`). '
            'Do **not** edit these in `dspace.cfg`; edit '
            '`environments/<env>/backend-cm.jsonnet` in `deepblue-documents-kube` instead.'
        ))

    # 2. Workshop shares production database
    w_db = cfgs['workshop'].get('db.url', '')
    p_db = cfgs['production'].get('db.url', '')
    d_db = cfgs['demo'].get('db.url', '')
    if w_db == p_db and w_db != d_db:
        findings.append((
            'workshop shares the production database credentials',
            f'- `db.url` = `{p_db}` in both production and workshop — workshop '
            'connects to the **production database**.\n'
            '- `db.username` / `db.password` are also identical in production and workshop.\n\n'
            '⚠️  Workshop is **not** an isolated test environment with respect to data. '
            'The production assetstore is mounted read-only in workshop '
            '(`readOnly: true`), but database writes (deposits, metadata edits, '
            'workflow actions) **affect production data**.'
        ))

    # 3. Demo uses local test database
    if 'localhost' in d_db and 'prod' not in d_db:
        d_fs = cfgs['demo'].get('filestorage.dir', '')
        findings.append((
            'demo uses a local/test assetstore and database',
            f'- `filestorage.dir` = `{d_fs}` — files stored relative to the DSpace '
            'install directory (ephemeral in a container).\n'
            f'- `db.url` = `{d_db}` with username `{cfgs["demo"].get("db.username", "")}` '
            '— a lightweight local database, not production.\n\n'
            'demo is fully isolated from production data.'
        ))

    # 4. Production has real-world identifiers
    p_handle = cfgs['production'].get('handle.prefix', '')
    d_handle = cfgs['demo'].get('handle.prefix', '')
    p_doi = cfgs['production'].get('identifier.doi.prefix', '')
    d_doi = cfgs['demo'].get('identifier.doi.prefix', '')
    pw_working = 'identifier.doi.password_working' in cfgs['production']
    if p_handle != d_handle:
        findings.append((
            'Production has unique real-world identifiers',
            f'- `handle.prefix` = `{p_handle}` is the registered U-M prefix at CNRI. '
            f'demo and workshop use `{d_handle}` (test/dummy).\n'
            f'- `identifier.doi.prefix` = `{p_doi}` is the registered Deep Blue Data '
            f'prefix at DataCite. demo and workshop use `{d_doi}` (test).\n' +
            ('- Production has an extra `identifier.doi.password_working` field absent '
             'from demo and workshop.\n' if pw_working else '')
        ))

    # 5. nodoi.email
    p_nodoi = cfgs['production'].get('nodoi.email', '')
    d_nodoi = cfgs['demo'].get('nodoi.email', '')
    if p_nodoi != d_nodoi:
        findings.append((
            '`nodoi.email` differs between production and the other environments',
            f'- Production: `{p_nodoi}` — ⚠️  this does not appear to be a valid '
            'U-M address; it should be reviewed.\n'
            f'- demo and workshop: `{d_nodoi}`.'
        ))

    # 6. Properties identical in all three (notable ones only)
    notable_shared = [
        k for k in ['ip.bioIPsRange1', 'ip.bioIPsRange2', 'api.user.key',
                    'mail.server', 'mail.from.address']
        if k in identical
    ]
    if notable_shared:
        findings.append((
            'IP ranges, API key, and mail settings are identical across all three environments',
            'All three environments share the same values for:\n\n' +
            '\n'.join(f'- `{k}`' for k in notable_shared) +
            '\n\nChanges to these properties must be applied to all three secrets.'
        ))

    # ── Assemble document ─────────────────────────────────────────────────────
    now = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
    out: list[str] = [
        '# Config File Comparison: demo vs production vs workshop',
        '',
        f'> Generated {now} by `python3 dotpy/gen_delta.py`.',
        '> Re-run after fetching fresh copies of the three cfg files from the cluster.',
        '',
        'Comparing the three decrypted Kubernetes config files:',
        '',
        '- `from-kube.demo.dspace.cfg`',
        '- `from-kube.production.dspace.cfg`',
        '- `from-kube.workshop.dspace.cfg`',
        '',
        '> **Note:** these `*.cfg` files are gitignored and are never committed.',
        '> Fetch them before running this script (see `README.md`).',
        '',
        '---',
        '',
        '## Summary Table',
        '',
        f'Properties that differ across environments ({len(differing)} of {len(all_keys)} total):',
        '',
        md_table(headers, rows),
        '',
        '---',
        '',
        '## Key Findings',
        '',
    ]

    for i, (title, body) in enumerate(findings, 1):
        out.append(f'### {i}. {title}')
        out.append('')
        out.append(body)
        out.append('')

    out += [
        '---',
        '',
        '## Recommendations',
        '',
        '1. **Do not edit ConfigMap-controlled properties in `dspace.cfg`.**  '
        'Properties such as `dspace.server.url`, `dspace.ui.url`, `db.url`,  '
        '`solr.server`, `handle.prefix`, `identifier.doi.prefix`, and mail  '
        'settings are overridden at runtime by the `backend-environment` ConfigMap.  '
        'Edit `environments/<env>/backend-cm.jsonnet` in `deepblue-documents-kube` instead.',
        '',
        '2. **Isolate workshop from production data.**  '
        'Workshop should have its own database and assetstore.  '
        'The current setup (shared `dspace-prod` database) is dangerous for testing.',
        '',
        '3. **Review `nodoi.email` in production** — the current value does not appear  '
        'to be a valid U-M address.',
        '',
        '4. **Properties shared by all three environments** (IP ranges, `api.user.key`,  '
        'mail settings) must be updated in all three secrets simultaneously.',
        '',
    ]

    return '\n'.join(out)


# ── entry point ───────────────────────────────────────────────────────────────

def main():
    script_dir = Path(__file__).parent
    default_config_dir = script_dir.parent / 'backend' / 'config'

    config_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else default_config_dir

    # Verify and load cfg files
    cfgs: dict[str, dict] = {}
    for env in ENVS:
        fname = f'from-kube.{env}.dspace.cfg'
        fpath = config_dir / fname
        if not fpath.exists():
            print(
                f'ERROR: {fpath} not found.\n'
                f'Fetch it from the cluster:\n'
                f'  kubectl -n {env} get secret dspace-cfg \\\n'
                f'    -o jsonpath="{{.data.dspace\\.cfg}}" | base64 --decode \\\n'
                f'    > {fpath}',
                file=sys.stderr,
            )
            sys.exit(1)
        cfgs[env] = parse_cfg(fpath)
        print(f'Parsed {fpath} ({len(cfgs[env])} properties)', file=sys.stderr)

    content = generate(cfgs)

    # Determine output destination
    if len(sys.argv) > 2:
        out_arg = sys.argv[2]
        if out_arg == '-':
            print(content)
            return
        out_path = Path(out_arg)
    else:
        out_path = config_dir / 'DELTA.md'

    out_path.write_text(content + '\n', encoding='utf-8')
    print(f'Written to {out_path}', file=sys.stderr)


if __name__ == '__main__':
    main()

