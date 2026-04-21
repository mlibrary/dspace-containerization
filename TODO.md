# TODO


## Scrub Deleted `.cpt` Files from Git History
The five encrypted config files (`backend/config/*.cpt`) and the production log
(`backend/logs/dspace.log.2023-11-01`) were deleted from the working tree in
`DEEPBLUE-466/Refactor`, but they remain in prior commits on `main` after the
PR merges. If any `.cpt` file ever held real credentials (even rotated ones),
they should be scrubbed from history entirely. This is a separate post-merge
cleanup PR/operation — it must not block the `DEEPBLUE-466/Refactor` merge.

- [ ] After `DEEPBLUE-466/Refactor` merges, verify with the team that the `.cpt` passphrase has been rotated and is no longer in active use
- [ ] Create a dedicated cleanup branch (e.g. `chore/scrub-cpt-history`)
- [ ] Install `git-filter-repo` if not already present: `pip install git-filter-repo` or `brew install git-filter-repo`
- [ ] Rewrite history to remove all `.cpt` files and the production log: `git filter-repo --path backend/config/ --path backend/logs/ --invert-paths`
- [ ] Force-push the rewritten `main`: `git push --force origin main`
- [ ] Notify all team members to re-clone or reset their local copies: `git fetch --all && git reset --hard origin/main`
- [ ] Update any open PRs that were based on the old history (rebase onto the rewritten `main`)
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


