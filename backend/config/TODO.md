# backend/config

This directory is copied into the DSpace image at build time:

```
COPY ./backend/config/ $DSPACE_INSTALL/config/
```

## Files

| File | Purpose |
|------|---------|
| `local.cfg` | Local development overrides (OIDC disabled, etc.) |
| `*.dspace.cfg.cpt` | Encrypted production/staging config snapshots (not loaded by DSpace directly) |

## Recommendation: replace the dspace.cfg symlink with local.cfg

The current production deployment uses `SYMLINK_SECRETS=true` to replace the
default `dspace.cfg` entirely with a Kubernetes Secret mount:

```dockerfile
ln -sf $DSPACE_INSTALL/secret/dspace.cfg $DSPACE_INSTALL/config/dspace.cfg
```

A cleaner approach is to **leave the default `dspace.cfg` in place** and instead
mount a `local.cfg` from a Kubernetes Secret. Because DSpace 7 loads `local.cfg`
*after* `dspace.cfg`, any property defined in `local.cfg` overrides the default.
Only the production-specific values need to appear in the Secret — no need to
maintain a complete fork of `dspace.cfg`.

The `SYMLINK_SECRETS` block in `backend.dockerfile` would become:

```dockerfile
ARG SYMLINK_SECRETS=false
RUN if [ "$SYMLINK_SECRETS" = "true" ]; then \
      ln -sf $DSPACE_INSTALL/secret/local.cfg \
             $DSPACE_INSTALL/config/local.cfg && \
      ln -sf $DSPACE_INSTALL/secret2/authentication-oidc.cfg \
             $DSPACE_INSTALL/config/modules/authentication-oidc.cfg; \
    fi
```

And the Kubernetes Secret for `local.cfg` would contain only the overrides
needed for that environment, for example:

```properties
dspace.server.url     = https://backend.deepblue-documents.lib.umich.edu/server
dspace.ui.url         = https://deepblue-documents.lib.umich.edu
db.url                = jdbc:postgresql://<host>:5432/dspace
filestorage.dir       = /dspace

plugin.sequence.org.dspace.authenticate.AuthenticationMethod = \
    org.dspace.authenticate.PasswordAuthentication, \
    org.dspace.authenticate.OidcAuthentication
```

### Benefits

- No more "cp nonsense" in the Kubernetes backend deployment command
  (noted by Anthony Thomas — the copy was a workaround because Kubernetes
  cannot mount a Secret as a single file into an existing directory).
- The Secret stays small and readable — only the delta from defaults.
- `dspace.cfg` is no longer a diverging fork that must be kept in sync with
  upstream DSpace releases.
- Local development already uses this pattern: `backend/config/local.cfg` is
  copied into the image and disables OIDC (which requires the live U-Mich
  weblogin service) for the local Docker Compose stack.

