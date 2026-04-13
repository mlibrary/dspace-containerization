# dspace-containerization
University of Michigan Library containerization of [DSpace](https://dspace.lyrasis.org/)
## Overview

A source image is created by pulling source code from the library's forks of DSpace: https://github.com/mlibrary/dspace-angular and  https://github.com/mlibrary/DSpace. The source image is then used to create the frontend, backend, and solr images. These images, along with a database image, are then configured and deployed to create an instance of the DSpace application.  

Essentially there are two, for lack of a better word, contexts: local and remote. Local will be used to refer to your local development environment, or more specifically, Docker Desktop. Remote will be used to refer a Kubernetes cluster. The primary differences between these two contexts being how images are built, where they are stored, and how they are deployed. Local images are built via the `docker compose build` command, stored locally in Docker Desktop, and deployed via `docker compose up -d` command. Remote images are built via GitHub Actions, stored remotely in GitHub Packages, and deployed to [Kubernetes](https://github.com/mlibrary/dspace-containerization/blob/main/dspace) ([OpenShift](https://github.com/mlibrary/dspace-containerization/blob/main/dspace-uid)) typically using `kubectl` (`oc`) to apply the appropriate deployment yaml files.

It is recommend that you first get an instance of DSpace running locally via `docker compose` prior to attempting to get an instance of DSpace running remotely in Kubernetes.


## Building and running locally

### Quick Start
1. (Optional) Copy `.env.example` to `.env` and adjust build arguments as needed.
2. Build images:
   ```shell
   docker compose build
   ```
3. Start the core services:
   ```shell
   docker compose up -d
   ```

### Optional Services
- The `apache` service is optional for most local development. To include it, run:
  ```shell
  docker compose --profile optional up -d apache
  ```

### Service URLs
| URL                                     | Container | Comments                                     |
|-----------------------------------------|-----------|----------------------------------------------|
| http://localhost:4000/home              | frontend  | Angular GUI                                  |
| jdbc:postgresql://localhost:5432/dspace | db        | PostgreSQL  (user: dspace, password: dspace) |
| http://localhost:8080/server            | backend   | Server API                                   |
| http://localhost:8983/solr              | solr      | Solr GUI                                     |
| http://localhost:8888/                  | apache    | Apache Web Server (optional)                 |

### Build Arguments
Build arguments can be set in your `.env` file:
```
GITHUB_BRANCH=umich
DSPACE_VERSION=dspace-7.6
JDK_VERSION=11
```

### Notes
- Debugging ports (e.g., 8009, 9876) are not exposed by default. Add them to `docker-compose.yml` if needed.

## References

## References
* https://dspace.lyrasis.org/
* https://wiki.lyrasis.org/display/DSPACE/
