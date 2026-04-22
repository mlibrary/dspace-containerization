# DONE

## 2026-04-22T00:00:00 — Backend Bin Scripts README
Documented all 58 scripts and data files in `backend/bin/` (excluding
`README.md` itself and the CSV inventory sheets under `sheets/`). Initial
descriptions were synthesised from the v2 CSV inventory, then corrected via
systematic file-by-file review. Thirteen factual errors were found and fixed;
all corrections are documented as numbered footnotes in a "Review Notes"
section appended to the README. All six Markdown tables pass `check_tables.py`
validation.

- [x] Extract descriptions for all files from inventory v2 CSV
- [x] Document top-level scripts: `additonal_stats_data`, `consolidate_ips`, `embargo-item`, `find_crawlers`, `ip_stats_data`, `meta_file`, `meta_file_delete`, `meta_file_orcid`, `monthly_report`, `prep-logs`, `remove_ips`, `update_all_ip_table`
- [x] Document `aptrust/` directory: `email-aptrust-bagging-errors`, `metadata2aptrust-info.xsl`, `metadata2bag-info.xsl`, `move-to-aptrust-regular`, `report-aptrust-status`, `saxon9he.jar`
- [x] Document `cronjobs/` directory: `check-checksum`, `filter-media-cronjob`, `find-items-to-unrestrict-bio`, `find-items-to-unrestrict-rack`, `meta_file_author`, `meta_file_delete`, `meta_file_desc`, `perl_mailer`, `pubmedV2`, `report-about-dearborn-items`, `report-double-original`, `report-embargo`, `report-tombstone`, `report-too-many-authors`, `report-too-many-db-connections`, `update_author_list_too_long`
- [x] Document `monthlies/` directory: `JOURNAL_SUBJECTS`, `change-type-martha`, `check-retiree.rb`, `clear-bit-description`, `find-authors-monthly`, `find-bit-change-perpmission`, `prepare-wiley`, `prepare-wiley_1`, `prepare-wiley_2`, `prepare-wiley_3`, `prepare-wiley_4`, `replace-funny-char-for-wiley`, `report-martha-types`, `report-users-out`, `update-orcid-values-monthly`
- [x] Document `rackham/` directory: `prepare-rackham`, `report-for-rackham`
- [x] Document `stats_monthlies/` directory: `StatsUtils.pm`, `find-alicia-stats`, `find-size-stats`, `monthly_admin_report`, `monthly_admin_report_for_bentley`, `monthly_individual_report`, `monthly_individual_report_based_on_author`
- [x] Write `backend/bin/README.md` with all sections
- [x] Validate README.md tables with `python3 dotpy/check_tables.py backend/bin/README.md`
- [x] Verify with the developer that the task is complete

## 2026-04-21T00:00:00 — Address Minor Issues from PR Review (DEEPBLUE-466/Refactor)
Resolved all actionable follow-up items flagged during the PR review: consolidated
`dspace/backend.dockerfile` ant/wget layers, merged `dspace-uid/solr.dockerfile`
`RUN` commands, replaced non-ASCII en-dashes in the Makefile, made the smoke-test
authn assertion format-agnostic with jq, removed redundant CI `--build-arg` flags,
and removed a cosmetic double blank line. The git history scrub is tracked as a
separate post-merge task.

- [x] `dspace/backend.dockerfile`: Consolidate the ant/wget `RUN` layers into one (consistent with `backend.dockerfile`)
- [x] `dspace-uid/solr.dockerfile`: Merge the five `RUN` commands (deluser, groupadd, useradd, two chowns) into a single layer; manually verify `deluser` works against the actual published `dspace-solr` base image
- [x] `Makefile`: Replace the non-ASCII en-dash (`–`) in the `ensure-source` echo strings with an ASCII hyphen (`-`) or plain wording
- [x] `tests/smoke.sh`: Make the authn assertion format-agnostic (use `jq` to check `"authenticated": false` instead of the spacing-sensitive string `"authenticated" : true`)
- [x] `.github/workflows/ci.yml`: Remove the redundant `--build-arg DSPACE_VERSION` / `--build-arg JDK_VERSION` flags from the `docker compose build` step (compose already reads them from the `env:` block)
- [x] `.github/workflows/ci.yml`: Remove the double blank line after the Checkout step (cosmetic)
- [x] git history: Determine whether any deleted `.cpt` files contained real credentials; if so, run `git filter-repo` to scrub them before merging (files are ccrypt-encrypted — requires the decryption key to inspect; developer must verify)
- [x] Verify the current state of the project achieves the task goal
- [x] Verify with the developer that the task is complete

## 2026-04-21T00:00:00 — Guidelines for Coding Agents
Established `AGENTS.md` and ensured all developer-facing documentation directs
coding agents to read and follow those guidelines at the start of every session.

- [x] Create `AGENTS.md` with CLI paging, task-tracking, and Markdown formatting rules
- [x] Add "For AI Coding Agents" section to `README.md` pointing to `AGENTS.md`
- [x] Update `AGENTS.md`: prepend `DONE.md` entries to keep list in reverse chronological order
- [x] Update `AGENTS.md`: use task/subtask structure; move a task to `DONE.md` only when all subtasks are complete
- [x] Verify the current state of the project accomplishes the task goal
- [x] Verify with the developer that the task is complete

