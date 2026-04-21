# TODO

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


