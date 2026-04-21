# dspace-containerization
Containerization and deployment infrastructure for [Deep Blue Documents](https://deepblue.lib.umich.edu/), the University of Michigan Library's institutional repository, built on [DSpace 7+](https://dspace.lyrasis.org/).

## For AI Coding Agents

> **If you are an AI coding agent (GitHub Copilot, Claude, Cursor, or similar), read [`AGENTS.md`](AGENTS.md) before taking any action in this repository.**
> It contains mandatory guidelines for CLI usage, task tracking, and Markdown formatting that apply to every agent session.

## Overview

This repository is the source of truth for building and deploying **Deep Blue Documents** — U-M Library's DSpace-based institutional repository. It produces Docker images from the library's own forks of DSpace ([`mlibrary/DSpace`](https://github.com/mlibrary/DSpace)) and the Angular frontend ([`mlibrary/dspace-angular`](https://github.com/mlibrary/dspace-angular)), layering U-M-specific configuration and tooling on top of upstream DSpace.

A shared **source image** is built first by cloning those forks. It is then consumed by the `frontend`, `backend`, and `solr` service images. Together with a `db` image, these form a complete DSpace stack that can be run locally via Docker Compose or deployed remotely to Kubernetes / OpenShift.

There are two deployment contexts:
- **Local** — Docker Desktop; images built with `docker compose build`, deployed with `docker compose up -d`.
- **Remote** — Kubernetes/OpenShift cluster; images built by GitHub Actions, stored in GitHub Packages, and deployed by applying the YAML manifests in [`dspace/`](dspace) (Kubernetes) or [`dspace-uid/`](dspace-uid) (OpenShift).

It is recommended to get the stack running locally via Docker Compose before attempting a remote deployment.

## For other institutions

> While this repository is configured for the University of Michigan's **Deep Blue Documents** service, it is designed to serve as a **reference architecture** for how to containerize and orchestrate a heavily customized DSpace 7+ environment using Docker Compose, Kubernetes, and OpenShift.
>
> **What is reusable:** the multi-stage Dockerfile patterns, `docker-compose.yml` service structure, Makefile workflow, smoke-test suite (`tests/`), and GitHub Actions CI pipeline (`.github/workflows/ci.yml`) are general-purpose and straightforward to adapt.
>
> **What is U-M-specific:** the source forks (`mlibrary/DSpace`, `mlibrary/dspace-angular`), the `GITHUB_BRANCH=umich` default, backend scripts in `backend/bin/`, and `backend/local.cfg`.
>
> To adapt this for your own institution, point `GITHUB_BRANCH` (or a fork of your own) at your customized DSpace source and replace `backend/local.cfg` with your own overrides. Note that `backend/local.cfg` is only copied into images built by the root `backend.dockerfile` (local dev and `ci.yml`); the `dspace/backend.dockerfile` used to build published production/staging images does **not** copy it — configuration for those environments is supplied at runtime via environment variables or mounted Kubernetes Secrets.


## Building and running locally

### Quick Start
1. (Optional) Copy `.env.example` to `.env` and adjust build arguments as needed.
2. Build the shared **source image** (required once, and whenever the source branch changes):
   ```shell
   docker build -t dspace-containerization-source .
   ```
   > The `frontend`, `backend`, and `solr` images depend on this image at build time.
   > Use `make build` (see [Makefile](Makefile)) to build source + all compose services in one step.
3. Build the compose service images:
   ```shell
   docker compose build
   ```
4. Start the core services:
   ```shell
   docker compose up -d
   ```
   > `db` and `solr` include healthchecks; `backend` will not start until both are healthy.

### Optional Services
The `apache` and `express` services are not started by default. To include them:
```shell
docker compose --profile optional up -d
```
Or start a single optional service:
```shell
docker compose --profile optional up -d apache
docker compose --profile optional up -d express
```

### Service URLs
| URL                                     | Container | Comments                                                                     |
|-----------------------------------------|-----------|------------------------------------------------------------------------------|
| http://localhost:4000/                  | frontend  | Angular GUI (SSR app shell; Angular router handles `/home` etc. client-side) |
| jdbc:postgresql://localhost:5432/dspace | db        | PostgreSQL  (user: dspace, password: dspace)                                 |
| http://localhost:8080/server            | backend   | Server API                                                                   |
| http://localhost:8983/solr              | solr      | Solr GUI                                                                     |
| http://localhost:8888/                  | apache    | Apache Web Server – optional (CGI stats scripts)                             |
| http://localhost:3000/metrics           | express   | Prometheus metrics endpoint – optional                                       |

### Build Arguments
Build arguments are read from `.env` (copy from `.env.example`):
```
GITHUB_BRANCH=umich
DSPACE_VERSION=7.6
JDK_VERSION=17
DSPACE_UI_HOST=0.0.0.0
DSPACE_REST_HOST=backend
```
- `GITHUB_BRANCH` — branch in the mlibrary forks used to build the source image.
- `DSPACE_VERSION` — version suffix for DSpace Docker Hub images (e.g. `7.6` → image tag `dspace-7.6`). Use `7.6` here; the current upstream DSpace patch release targeted by this configuration is **7.6.0**.
- `JDK_VERSION` — Java version for the backend Tomcat image (must be `17`; JDK11 is no longer supported). The build uses `eclipse-temurin` images — the official successor to the deprecated `openjdk` Docker Hub images.
- `DSPACE_UI_HOST` — hostname the Angular SSR server binds to. Use `0.0.0.0` for local Docker development (Node.js 18+ resolves `localhost` to `::1`, breaking Docker port-mapping). Set to the public hostname for staging/production.
- `DSPACE_REST_HOST` — hostname the Angular SSR server (inside the frontend container) uses to reach the backend REST API over Docker's internal DNS. Use `backend` (the Docker service name) for local development. The browser-side Angular client re-uses the `dspaceServer` URL from the HAL root at runtime.

`docker-compose.yml` passes `DSPACE_VERSION` and `JDK_VERSION` automatically to the relevant service builds via `build.args`.

### Notes
- Debugging ports (e.g., 8009, 9876) are not exposed by default. Add them to `docker-compose.yml` if needed.
- The `backend` service uses `depends_on` with `condition: service_healthy` for `db` and `solr`, and the `frontend` service waits for `backend` to be healthy, ensuring correct startup ordering without manual delays.
- Use `make` targets (see [Makefile](Makefile)) for common workflows: `make build`, `make up`, `make down`, `make clean`.
- **`backend/local.cfg`** disables OIDC authentication for local dev and supplies placeholder values for `ip.bioIPsRange1` / `ip.bioIPsRange2`. `OidcAuthenticationBean` is still instantiated by Spring even when removed from the authentication plugin sequence, and its initialisation path calls `String.split()` on those properties unconditionally — omitting them causes a `NullPointerException` that returns HTTP 500 on every `/server/api` endpoint and the actuator. This file is only copied into images built by the root `backend.dockerfile` (local dev and `ci.yml`). The `dspace/backend.dockerfile`, used to build the production/staging images published to `ghcr.io`, does **not** copy it at all.

## Integration Testing

A shell-based smoke test suite lives in [`tests/`](tests/). It requires only `bash` and `curl`.

### Quick run (stack already up)
```shell
bash tests/smoke.sh
```

### Full run (start → wait → test)
```shell
make test
```
This is equivalent to:
```shell
make up                     # docker compose up -d
bash tests/wait-for-stack.sh  # poll until backend/solr/frontend are ready
bash tests/smoke.sh           # run all assertions
```

### What is tested

| Layer            | Endpoint                           | Assertion                                                                  |
|------------------|------------------------------------|----------------------------------------------------------------------------|
| Backend REST API | `GET /server/api`                  | HTTP 200, HAL `_links` present                                             |
| Backend REST API | `GET /server/api`                  | `dspaceVersion` and `dspaceServer` fields present                          |
| Backend REST API | `GET /server/api/core/communities` | HTTP 200                                                                   |
| Backend REST API | `GET /server/api/core/collections` | HTTP 200                                                                   |
| Backend REST API | `GET /server/api/authn/status`     | HTTP 200, `"authenticated":false`                                          |
| Backend Actuator | `GET /server/actuator/health`      | `"status":"UP"` or `"UP_WITH_ISSUES"`                                      |
| Solr             | `GET /solr/admin/info/system`      | HTTP 200, version info present                                             |
| Solr             | `GET /solr/admin/cores`            | All four DSpace cores present (`authority`, `oai`, `search`, `statistics`) |
| Solr             | `GET /solr/search/admin/ping`      | HTTP 200                                                                   |
| Frontend         | `GET /`                            | HTTP 200, no `ng-error` boundary                                           |
| Frontend (SSR)   | `GET /communities/`                | HTTP 200, `ds-root` element present, `DSpace` title present                |

### CI (GitHub Actions)
The workflow [`.github/workflows/ci.yml`](.github/workflows/ci.yml) is the primary CI workflow. It runs automatically on every push to **any branch**, on pull-requests targeting `umich` or `main`, and can also be triggered manually (`workflow_dispatch`) with optional `dspace_version`, `jdk_version`, and `source_branch` inputs. It is scoped to the canonical `mlibrary/dspace-containerization` repository so fork runs do not consume runner minutes.

Additional image-building workflows live alongside `ci.yml` and can be used to publish individual service images to GitHub Packages independently of the full stack test:

| Workflow                       | Purpose                                          |
|--------------------------------|--------------------------------------------------|
| `build-source-image.yml`       | Builds and publishes the shared source image     |
| `build-dspace-images.yml`      | Builds frontend, backend, and solr images        |
| `build-db-image.yml`           | Builds the PostgreSQL db image                   |
| `build-apache-image.yml`       | Builds the optional Apache image                 |
| `build-express-image.yml`      | Builds the optional Express metrics image        |
| `build-dspace-uid-images.yml`  | OpenShift UID-safe variants of the DSpace images |
| `build-db-uid-image.yml`       | OpenShift UID-safe db image                      |
| `build-apache-uid-image.yml`   | OpenShift UID-safe Apache image                  |
| `delete-old-workflow-runs.yml` | Housekeeping – prunes stale workflow run history |

> **Note on `GITHUB_BRANCH` vs `SOURCE_BRANCH`:** locally (Makefile / `.env`) the build arg is called `GITHUB_BRANCH` and is passed directly to `docker build`.  In the CI workflow it is stored in an env var called `SOURCE_BRANCH` — because GitHub Actions reserves all variables prefixed with `GITHUB_` and will fail the job if one is set in an `env:` block — then forwarded to Docker as `--build-arg GITHUB_BRANCH=${SOURCE_BRANCH}`, so the `Dockerfile` and `Makefile` require no changes.

## References
* https://dspace.lyrasis.org/
* https://wiki.lyrasis.org/display/DSPACE/
