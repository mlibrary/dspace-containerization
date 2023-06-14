# dspace-containerization
University of Michigan Library containerization of DSpace
## Overview
A source image is created by pulling source code from the library's forks of DSpace: https://github.com/mlibrary/dspace-angular and  https://github.com/mlibrary/DSpace. The source image is then used to create the frontend, backend, and solr images. These images, along with a database image, are then configured and deployed to create an instance of the DSpace application.  

Essentially there are two, for lack of a better word, contexts: local and remote. Local will be used to refer to your local development environment, or more specifically, Docker Desktop. Remote will be used to refer a Kubernetes cluster. The primary differences between these two contexts being how images are built, where they are stored, and how they are deployed. Local images are built via the `docker compose build` command, stored locally in Docker Desktop, and deployed via `docker compose up -d` command. Remote images are built via GitHub Actions, stored remotely in GitHub Packages, and deployed to Kubernetes (OpenShift) typically using `kubectl` (`oc`) to apply the appropriate deployment yaml files.

It is recommend that you first get an instance of DSpace running locally via `docker compose` prior to attempting to get an instance of DSpace running remotely in Kubernetes.
## Building and running locally
```shell
docker compose build
docker compose up -d
```
## Building and running remotely
| Workflow                  | YAML                         | Packages                                                                                 |
|---------------------------|------------------------------|------------------------------------------------------------------------------------------|
| Build dspace images       | build-dspace-images.yml      | dspace-frontend:`tag`, dspace-backend:`tag`, dspace-solr:`tag`, dspace-db:`tag`          |
| Build dspace uid images   | build-dspace-uid-images.yml  | dspace-frontend:**uid**, dspace-backend:**uid**, dspace-solr:**uid**, dspace-db:**uid**  |
| Build dspace source image | build-source-image.yml       | dspace-source:`tag`                                                                      |
| Delete old workflow runs  | delete-old-workflow-runs.yml |                                                                                          |

### The above workflows need be run in the following order:
1. Build dspace source image
2. Build dspace images
3. Build dspace uid images
### Deploying to OpenShift
1. Hello
2. World!
3. 
