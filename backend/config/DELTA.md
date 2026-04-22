# Config File Comparison: demo vs production vs workshop

> Generated 2026-04-22T02:19:26Z by `python3 dotpy/gen_delta.py`.
> Re-run after fetching fresh copies of the three cfg files from the cluster.

Comparing the three decrypted Kubernetes config files:

- `from-kube.demo.dspace.cfg`
- `from-kube.production.dspace.cfg`
- `from-kube.workshop.dspace.cfg`

> **Note:** these `*.cfg` files are gitignored and are never committed.
> Fetch them before running this script (see `README.md`).

---

## Summary Table

Properties that differ across environments (25 of 263 total):

| Property                                                   | demo                                              | production                                       | workshop                                     |
|------------------------------------------------------------|---------------------------------------------------|--------------------------------------------------|----------------------------------------------|
| `alert.recipient`                                          | ${mail.admin}                                     | ulib-deepblue-documents-cron-reporting@umich.edu | ${mail.admin}                                |
| `cc.license.jurisdiction`                                  | us                                                | *(absent)*                                       | *(absent)*                                   |
| `core.authorization.collection-admin.submitters`           | false                                             | true                                             | true                                         |
| `core.authorization.community-admin.item-admin.cc-license` | *(absent)*                                        | false                                            | false                                        |
| `core.authorization.community-admin.item.create-bitstream` | *(absent)*                                        | true                                             | true                                         |
| `core.authorization.community-admin.item.delete-bitstream` | *(absent)*                                        | false                                            | false                                        |
| `db.password`                                              | *(redacted)*                                      | *(redacted)*                                     | *(redacted)*                                 |
| `db.url`                                                   | jdbc:postgresql://localhost:5432/dspace           | jdbc:postgresql://localhost:5432/dspace-prod     | jdbc:postgresql://localhost:5432/dspace-prod |
| `db.username`                                              | dspace                                            | dspace-prod                                      | dspace-prod                                  |
| `filestorage.dir`                                          | ${dspace.dir}                                     | /mnt/prod-assetstore                             | /mnt/prod-assetstore                         |
| `google.analytics.key`                                     | *(absent)*                                        | UA-12656561-1                                    | *(absent)*                                   |
| `handle.canonical.prefix`                                  | ${dspace.ui.url}/handle/                          | https://hdl.handle.net/                          | ${dspace.ui.url}/handle/                     |
| `handle.hide.listhandles`                                  | *(absent)*                                        | false                                            | false                                        |
| `handle.prefix`                                            | 123456789                                         | 2027.42                                          | 123456789                                    |
| `handle.remote-resolver.enabled`                           | *(absent)*                                        | true                                             | true                                         |
| `handle.use.uuid`                                          | *(absent)*                                        | true                                             | true                                         |
| `hidden.format`                                            | 86                                                | 39                                               | 39                                           |
| `identifier.doi.password`                                  | *(redacted)*                                      | *(redacted)*                                     | *(redacted)*                                 |
| `identifier.doi.password_working`                          | *(absent)*                                        | *(redacted)*                                     | *(absent)*                                   |
| `identifier.doi.prefix`                                    | 10.33577                                          | 10.7302                                          | 10.33577                                     |
| `nodoi.email`                                              | abcblancoj@umich.edu                              | depositsarefun@acm.org                           | abcblancoj@umich.edu                         |
| `sitemap.dir`                                              | ${dspace.dir}/sitemaps                            | ${dspace.dir}/data/sitemaps                      | ${dspace.dir}/data/sitemaps                  |
| `sitemap.path`                                             | *(absent)*                                        | sitemaps                                         | *(absent)*                                   |
| `upload.temp.dir`                                          | ${dspace.dir}/upload                              | ${dspace.dir}/data/ui-upload                     | ${dspace.dir}/upload                         |
| `webui.browse.index.2`                                     | author:metadata:dc.contributor.*\,dc.creator:text | author:metadata:dc.contributor.author:text       | author:metadata:dc.contributor.author:text   |

---

## Key Findings

### 1. `dspace.server.url` and `dspace.ui.url` are `localhost` in all three environments

All three config files have:

```
dspace.server.url = http://localhost:8080/server
dspace.ui.url     = http://localhost:4000
```

This is **intentional**. These values are always overridden at pod startup by environment variables injected from the `backend-environment` ConfigMap (`dspace__P__server__P__url`, `dspace__P__ui__P__url`). Do **not** edit these in `dspace.cfg`; edit `environments/<env>/backend-cm.jsonnet` in `deepblue-documents-kube` instead.

### 2. workshop shares the production database credentials

- `db.url` = `jdbc:postgresql://localhost:5432/dspace-prod` in both production and workshop — workshop connects to the **production database**.
- `db.username` / `db.password` are also identical in production and workshop.

⚠️  Workshop is **not** an isolated test environment with respect to data. The production assetstore is mounted read-only in workshop (`readOnly: true`), but database writes (deposits, metadata edits, workflow actions) **affect production data**.

### 3. demo uses a local/test assetstore and database

- `filestorage.dir` = `${dspace.dir}` — files stored relative to the DSpace install directory (ephemeral in a container).
- `db.url` = `jdbc:postgresql://localhost:5432/dspace` with username `dspace` — a lightweight local database, not production.

demo is fully isolated from production data.

### 4. Production has unique real-world identifiers

- `handle.prefix` = `2027.42` is the registered U-M prefix at CNRI. demo and workshop use `123456789` (test/dummy).
- `identifier.doi.prefix` = `10.7302` is the registered Deep Blue Data prefix at DataCite. demo and workshop use `10.33577` (test).
- Production has an extra `identifier.doi.password_working` field absent from demo and workshop.


### 5. `nodoi.email` differs between production and the other environments

- Production: `depositsarefun@acm.org` — ⚠️  this does not appear to be a valid U-M address; it should be reviewed.
- demo and workshop: `abcblancoj@umich.edu`.

### 6. IP ranges, API key, and mail settings are identical across all three environments

All three environments share the same values for:

- `ip.bioIPsRange1`
- `ip.bioIPsRange2`
- `api.user.key`
- `mail.server`
- `mail.from.address`

Changes to these properties must be applied to all three secrets.

---

## Recommendations

1. **Do not edit ConfigMap-controlled properties in `dspace.cfg`.**  Properties such as `dspace.server.url`, `dspace.ui.url`, `db.url`,  `solr.server`, `handle.prefix`, `identifier.doi.prefix`, and mail  settings are overridden at runtime by the `backend-environment` ConfigMap.  Edit `environments/<env>/backend-cm.jsonnet` in `deepblue-documents-kube` instead.

2. **Isolate workshop from production data.**  Workshop should have its own database and assetstore.  The current setup (shared `dspace-prod` database) is dangerous for testing.

3. **Review `nodoi.email` in production** — the current value does not appear  to be a valid U-M address.

4. **Properties shared by all three environments** (IP ranges, `api.user.key`,  mail settings) must be updated in all three secrets simultaneously.

