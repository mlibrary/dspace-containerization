# dspace-containerization
University of Michigan Library containerization of [DSpace](https://dspace.lyrasis.org/)
## Overview

A source image is created by pulling source code from the library's forks of DSpace: https://github.com/mlibrary/dspace-angular and  https://github.com/mlibrary/DSpace. The source image is then used to create the frontend, backend, and solr images. These images, along with a database image, are then configured and deployed to create an instance of the DSpace application.  

Essentially there are two, for lack of a better word, contexts: local and remote. Local will be used to refer to your local development environment, or more specifically, Docker Desktop. Remote will be used to refer a Kubernetes cluster. The primary differences between these two contexts being how images are built, where they are stored, and how they are deployed. Local images are built via the `docker compose build` command, stored locally in Docker Desktop, and deployed via `docker compose up -d` command. Remote images are built via GitHub Actions, stored remotely in GitHub Packages, and deployed to [Kubernetes](https://github.com/mlibrary/dspace-containerization/blob/main/dspace) ([OpenShift](https://github.com/mlibrary/dspace-containerization/blob/main/dspace-uid)) typically using `kubectl` (`oc`) to apply the appropriate deployment yaml files.

It is recommend that you first get an instance of DSpace running locally via `docker compose` prior to attempting to get an instance of DSpace running remotely in Kubernetes.


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
| URL                                     | Container | Comments                                              |
|-----------------------------------------|-----------|-------------------------------------------------------|
| http://localhost:4000/home              | frontend  | Angular GUI                                           |
| jdbc:postgresql://localhost:5432/dspace | db        | PostgreSQL  (user: dspace, password: dspace)          |
| http://localhost:8080/server            | backend   | Server API                                            |
| http://localhost:8983/solr              | solr      | Solr GUI                                              |
| http://localhost:8888/                  | apache    | Apache Web Server – optional (CGI stats scripts)      |
| http://localhost:3000/metrics           | express   | Prometheus metrics endpoint – optional                |

### Build Arguments
Build arguments are read from `.env` (copy from `.env.example`):
```
GITHUB_BRANCH=umich
DSPACE_VERSION=7.6
JDK_VERSION=11
```
- `GITHUB_BRANCH` — branch in the mlibrary forks used to build the source image.
- `DSPACE_VERSION` — version suffix for DSpace Docker Hub images (e.g. `7.6` → image tag `dspace-7.6`). Target: **7.6.6** (Dec 2025).
- `JDK_VERSION` — Java version for the backend Tomcat image (`11` or `17`).

`docker-compose.yml` passes `DSPACE_VERSION` and `JDK_VERSION` automatically to the relevant service builds via `build.args`.

### Notes
- Debugging ports (e.g., 8009, 9876) are not exposed by default. Add them to `docker-compose.yml` if needed.
- The `backend` service uses `depends_on` with `condition: service_healthy` for `db` and `solr`, ensuring correct startup ordering without manual delays.
- Use `make` targets (see [Makefile](Makefile)) for common workflows: `make build`, `make up`, `make down`, `make clean`.

## References
* https://dspace.lyrasis.org/
* https://wiki.lyrasis.org/display/DSPACE/
