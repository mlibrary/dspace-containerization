# TODO

## Address Minor Issues from PR Review (DEEPBLUE-466/Refactor)
Clean up the small follow-up items flagged during the PR review of the
`DEEPBLUE-466/Refactor` branch. None are blockers, but resolving them will
keep the codebase consistent and avoid future confusion.

- [ ] `dspace/backend.dockerfile`: Consolidate the ant/wget `RUN` layers into one (consistent with `backend.dockerfile`)
- [ ] `dspace-uid/solr.dockerfile`: Merge the five `RUN` commands (deluser, groupadd, useradd, two chowns) into a single layer; manually verify `deluser` works against the actual published `dspace-solr` base image
- [ ] `Makefile`: Replace the non-ASCII en-dash (`–`) in the `ensure-source` echo strings with an ASCII hyphen (`-`) or plain wording
- [ ] `tests/smoke.sh`: Make the authn assertion format-agnostic (use `jq` to check `"authenticated": false` instead of the spacing-sensitive string `"authenticated" : true`)
- [ ] `.github/workflows/ci.yml`: Remove the redundant `--build-arg DSPACE_VERSION` / `--build-arg JDK_VERSION` flags from the `docker compose build` step (compose already reads them from the `env:` block)
- [ ] `.github/workflows/ci.yml`: Remove the double blank line after the Checkout step (cosmetic)
- [ ] git history: Determine whether any deleted `.cpt` files contained real credentials; if so, run `git filter-repo` to scrub them before merging
- [ ] Verify the current state of the project achieves the task goal
- [ ] Verify with the developer that the task is complete

## Fix Demo Backend: Solr Race Condition on Startup
The `demo` backend pod's Spring Boot context failed to initialize on 2026-04-15
because Solr was still loading when the backend started. Tomcat deployed the
`/server` webapp but Spring never finished — all `/server/api` requests return
a Tomcat 404 HTML page instead of a HAL JSON response, causing the SSR frontend
to throw `Error: undefined doesn't contain the link systemwidealerts` and return
HTTP 500 on `/documents`.

- [ ] Restart the `backend` deployment in the `demo` namespace to recover the running pod (Solr is now fully up): `kubectl rollout restart deployment/backend -n demo`
- [ ] Confirm `/server/api` returns HTTP 200 with a HAL JSON response after the restart
- [ ] Add a long-term fix: an `initContainer` or startup `readinessProbe` on the backend that waits for Solr to be ready before Spring Boot begins initializing
- [ ] Verify the current state of the project achieves the task goal
- [ ] Verify with the developer that the task is complete


