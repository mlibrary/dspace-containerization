# backend/config — Developer Guide: Updating `dspace.cfg` in Kubernetes

This directory contains supporting documentation for working with the
`dspace.cfg` Kubernetes Secrets across all three deployment environments.

## Files in This Directory

| File                              | Description                                                            |
|-----------------------------------|------------------------------------------------------------------------|
| `from-kube.production.dspace.cfg` | Decrypted `dspace.cfg` pulled from the **production** namespace        |
| `from-kube.workshop.dspace.cfg`   | Decrypted `dspace.cfg` pulled from the **workshop** namespace          |
| `from-kube.demo.dspace.cfg`       | Decrypted `dspace.cfg` pulled from the **demo** namespace              |
| `DELTA.md`                        | Auto-generated diff of the three configs; key differences and findings |

> **Note:** all `*.cfg` files in this directory are listed in `.gitignore`
> and are **never committed to the repository**. They contain secrets
> (database passwords, DOI credentials, API keys) and exist only as
> local working copies. Fetch them fresh from the cluster before editing
> (see [Step 1](#1-fetch-the-current-secret) below).

---

## Regenerating This Directory from Scratch

If the `from-kube.*.dspace.cfg` files and/or `DELTA.md` are missing, run the
following commands from the repository root.  You need `kubectl` access to
both clusters and the two contexts shown below.

### Step A — Fetch the cfg files from the cluster

```shell
# production runs on its own cluster
kubectl config use-context deepblue-documents-production
kubectl -n production get secret dspace-cfg \
  -o jsonpath="{.data.dspace\.cfg}" | base64 --decode \
  > backend/config/from-kube.production.dspace.cfg

# workshop and demo both run on the workshop cluster
kubectl config use-context deepblue-documents-workshop
kubectl -n workshop get secret dspace-cfg \
  -o jsonpath="{.data.dspace\.cfg}" | base64 --decode \
  > backend/config/from-kube.workshop.dspace.cfg
kubectl -n demo get secret dspace-cfg \
  -o jsonpath="{.data.dspace\.cfg}" | base64 --decode \
  > backend/config/from-kube.demo.dspace.cfg
```

### Step B — Regenerate DELTA.md

```shell
python3 dotpy/gen_delta.py backend/config
```

This parses the three cfg files, computes all differing properties, redacts
sensitive values, and writes `backend/config/DELTA.md`.  Run it any time the
cfg files change to keep the diff current.

---

## How `dspace.cfg` Is Deployed

In Kubernetes, `dspace.cfg` is stored as a **Secret** named `dspace-cfg` in
each environment's namespace. At pod startup the backend container copies the
secret to `/dspace/config/dspace.cfg` and starts Tomcat.

Changing the config requires:

1. Fetching the current secret from the cluster.
2. Editing the plain-text config.
3. Re-encoding and re-applying the secret.
4. Restarting the backend pod to pick up the change.

### Two-layer configuration: Secret + ConfigMap overrides

`dspace.cfg` (the Secret) is the base configuration, but a number of its
properties are **overridden at runtime** by environment variables injected
from the `backend-environment` **ConfigMap** in each namespace. DSpace 7+
uses Spring Boot's externalized configuration: an env var named
`dspace__P__server__P__url` overrides the `dspace.server.url` property in
`dspace.cfg` (the `__P__` sequence represents a `.`).

The ConfigMap is rendered by Tanka from `environments/<env>/backend-cm.jsonnet`
and sets these properties per environment:

| ConfigMap env var key                              | Overrides `dspace.cfg` property               |
|----------------------------------------------------|-----------------------------------------------|
| `dspace__P__server__P__url`                        | `dspace.server.url`                           |
| `dspace__P__ui__P__url`                            | `dspace.ui.url`                               |
| `db__P__url`                                       | `db.url`                                      |
| `solr__P__server`                                  | `solr.server`                                 |
| `handle__P__prefix`                                | `handle.prefix`                               |
| `identifier__P__doi__P__prefix`                    | `identifier.doi.prefix`                       |
| `dspace__P__name` / `dspace__P__shortname`         | `dspace.name` / `dspace.shortname`            |
| `pr__P__collectionid`                              | `pr.collectionid`                             |
| `hidden__P__format`                                | `hidden.format`                               |
| `mail__P__server`, `mail__P__server__P__port`, etc | Mail settings                                 |

> **Important:** if you change one of the above properties in `dspace.cfg`,
> the ConfigMap env var will still **win at runtime**. To change these
> properties for a Kubernetes environment, edit the corresponding
> `backend-cm.jsonnet` file in the `deepblue-documents-kube` repository
> and let Argo CD sync the change — do not edit the secret alone.
>
> Properties that are **not** in the ConfigMap (e.g. `db.password`,
> `identifier.doi.password`, IP ranges, `api.user.key`, `bitstream.virus.check`,
> `nodoi.email`) can only be changed via the `dspace-cfg` Secret.

> **⚠️ Warning — workshop shares the production database.**
> The `workshop` namespace points at the **production** PostgreSQL database
> (`dspace-prod`) via the `backend-environment` ConfigMap
> (`db__P__url = jdbc:postgresql://db:5432/dspace-prod`).
> The production assetstore is mounted in workshop, but as **read-only**
> (`readOnly: true`). Database writes (deposits, metadata edits, workflow
> actions) still affect production data. See `DELTA.md` for full details.

---

## Environment Reference

| Environment  | Kubernetes Namespace | Cluster API Server                                             | Public Hostname                               |
|--------------|----------------------|----------------------------------------------------------------|-----------------------------------------------|
| `production` | `production`         | `https://production.cluster.deepblue-documents.lib.umich.edu`  | `production.deepblue-documents.lib.umich.edu` |
| `workshop`   | `workshop`           | `https://workshop.cluster.deepblue-documents.lib.umich.edu`    | `workshop.deepblue-documents.lib.umich.edu`   |
| `demo`       | `demo`               | `https://workshop.cluster.deepblue-documents.lib.umich.edu`    | `demo.deepblue-documents.lib.umich.edu`       |

---

## Per-Environment Differences, Findings, and Recommendations

See **[`DELTA.md`](DELTA.md)** for the full, auto-generated comparison of all
three environments — including a table of every differing property, key
findings, and recommendations.  `DELTA.md` is regenerated from the live cfg
files by running:

```shell
python3 dotpy/gen_delta.py backend/config
```

---

## Step-by-Step: Updating `dspace.cfg`

Replace `<NAMESPACE>` below with `production`, `workshop`, or `demo` as
appropriate.

> **Run all commands from the repository root.** The `.gitignore` rule
> `backend/config/*.cfg` only protects files written into that directory.
> Using explicit `backend/config/` paths below ensures decrypted secrets
> are never accidentally staged or committed.

### 0. Select the correct kubectl context

`production` runs on a separate cluster from `workshop` and `demo`. Switch to
the right context before running any `kubectl` commands:

```shell
# for production:
kubectl config use-context deepblue-documents-production

# for workshop or demo (both run on the workshop cluster):
kubectl config use-context deepblue-documents-workshop
```

Confirm the active context at any time with:

```shell
kubectl config current-context
```

### 1. Fetch the current secret

```shell
kubectl -n <NAMESPACE> get secret dspace-cfg \
  -o jsonpath="{.data.dspace\.cfg}" | base64 --decode \
  > backend/config/from-kube.<NAMESPACE>.dspace.cfg
```

This writes the decrypted config to `backend/config/from-kube.<NAMESPACE>.dspace.cfg`,
which is covered by the `.gitignore` rule.

### 2. Edit the config

```shell
$EDITOR backend/config/from-kube.<NAMESPACE>.dspace.cfg
```

Refer to [DELTA.md](DELTA.md) for key per-environment configuration differences
to confirm you are using values appropriate to the target
environment. In particular:

- Do **not** use production `handle.prefix` (`2027.42`) or
  `identifier.doi.prefix` (`10.7302`) in `demo` or `workshop`.
- Do **not** use production database credentials in `demo`.

### 3. Re-encode to base64

```shell
base64 < backend/config/from-kube.<NAMESPACE>.dspace.cfg \
  > backend/config/from-kube.<NAMESPACE>.dspace.cfg.base64
```

### 4. Patch the secret directly (recommended)

```shell
kubectl -n <NAMESPACE> patch secret dspace-cfg \
  --type='json' \
  -p="[{\"op\":\"replace\",\"path\":\"/data/dspace.cfg\",\"value\":\"$(cat backend/config/from-kube.<NAMESPACE>.dspace.cfg.base64)\"}]"
```

Alternatively, copy the contents of
`backend/config/from-kube.<NAMESPACE>.dspace.cfg.base64`
into a local `config-secret.yaml` manifest and apply it:

```shell
kubectl apply -f config-secret.yaml
```

### 5. Restart the backend pod

The backend pod must be restarted to reload the mounted secret:

```shell
kubectl -n <NAMESPACE> rollout restart deployment backend
```

Wait for the rollout to complete:

```shell
kubectl -n <NAMESPACE> rollout status deployment backend
```

### 6. Verify

Check the backend logs for startup errors:

```shell
kubectl -n <NAMESPACE> logs -l app=backend --tail=100
```

Confirm the REST API is healthy:

```shell
# production:
curl -s https://backend.production.deepblue-documents.lib.umich.edu/server/actuator/health

# workshop:
curl -s https://backend.workshop.deepblue-documents.lib.umich.edu/server/actuator/health

# demo:
curl -s https://backend.demo.deepblue-documents.lib.umich.edu/server/actuator/health
```

---

## Working with Local Config Copies

The `from-kube.*.dspace.cfg` files are gitignored — they are never committed.
If they are missing, follow [Regenerating This Directory](#regenerating-this-directory-from-scratch)
above to fetch them from the cluster.

After applying a change to a secret, re-fetch to keep your local copy current:

```shell
kubectl config use-context deepblue-documents-production
kubectl -n production get secret dspace-cfg \
  -o jsonpath="{.data.dspace\.cfg}" | base64 --decode \
  > backend/config/from-kube.production.dspace.cfg

kubectl config use-context deepblue-documents-workshop
for NS in workshop demo; do
  kubectl -n $NS get secret dspace-cfg \
    -o jsonpath="{.data.dspace\.cfg}" | base64 --decode \
    > backend/config/from-kube.${NS}.dspace.cfg
done
```

Then re-run `gen_delta.py` to update `DELTA.md`:

```shell
python3 dotpy/gen_delta.py backend/config
```

Because these files contain secrets (passwords, API keys) they must stay
out of version control. The `.gitignore` rule `backend/config/*.cfg` ensures
this. Do not remove or override that rule.


