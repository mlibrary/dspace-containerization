# Building and running remotely (Kubernetes)

DSpace is hosted in the Library Information Technology (LIT) [Deepblue Documents Cluster](https://mlit.atlassian.net/l/cp/W410v0c7).
## build images
Run the GitHub action workflows in the following order to build the images that will be deployed to the library cluster.

| Workflow                                                                                                                     | Packages                                                                        |
|------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| [1. Build dspace source image](https://github.com/mlibrary/dspace-containerization/actions/workflows/build-source-image.yml) | dspace-source:`tag`                                                             |
| [2. Build dspace images](https://github.com/mlibrary/dspace-containerization/actions/workflows/build-dspace-images.yml)      | dspace-frontend:`tag`, dspace-backend:`tag`, dspace-solr:`tag`, dspace-db:`tag` |

NOTE:
* Production configuration is **not** baked into the backend image. It is supplied at runtime entirely via environment variables — non-sensitive settings (DSpace property overrides, IP ranges, mail settings, etc.) from a Kubernetes **ConfigMap**, and sensitive values (credentials, API keys) from Kubernetes **Secrets**. Both are managed in [deepblue-documents-kube](https://github.com/mlibrary/deepblue-documents-kube). This mirrors the pattern used locally: the `backend` service in `docker-compose.yml` sets the same `__P__`-encoded env vars for local development.
## configuration and deployment
Argo CD is used for configuration and deployment via [deepblue-documents-kube](https://github.com/mlibrary/deepblue-documents-kube) repository. 

## clusters
| Cluster    | Argo CD                                                        |
|------------|----------------------------------------------------------------|
| workshop   | https://cd.workshop.cluster.deepblue-documents.lib.umich.edu   |
| staging    | https://cd.staging.cluster.deepblue-documents.lib.umich.edu    |
| production | https://cd.production.cluster.deepblue-documents.lib.umich.edu |

## endpoints (workshop example)
| URL                                                                                | service  | comment               |
|------------------------------------------------------------------------------------|----------|-----------------------|
| https://workshop.deepblue-documents.lib.umich.edu/                                 | frontend | Angular GUI           |
| https://backend.workshop.deepblue-documents.lib.umich.edu/server                   | backend  | Server API            |
| https://backend.workshop.deepblue-documents.lib.umich.edu/rest                     | backend  | REST API (deprecated) |

## port-forward services (workshop example)
To reach other services, use the `kubectl --namespace=workshop port-forward service/<target> <port>:<port>` command.

| URL                                     | Container | Comments                                     |
|-----------------------------------------|-----------|----------------------------------------------|
| http://localhost:4000/home              | frontend  | Angular GUI                                  |
| jdbc:postgresql://localhost:5432/dspace | db        | PostgreSQL  (user: dspace, password: dspace) |
| http://localhost:8009/                  | backend   | AJP connector                                |
| http://localhost:8080/rest              | backend   | REST API (Deprecated)                        |
| http://localhost:8080/server            | backend   | Server API                                   |
| http://localhost:8888/                  | apache    | Apache Web Server                            |
| http://localhost:8983/solr              | solr      | Solr GUI                                     |
| http://localhost:9876/                  | frontend  | debugging???                                 |

## Known Security Concerns

The following issues exist in `backend.dockerfile` and should be addressed before any public-facing production deployment.

### 1. Legacy REST API served over HTTP
The last two lines of `backend.dockerfile` copy `rest_web.xml` from the DSpace test sources into the deployed REST webapp. This file disables the HTTPS-only constraint so the deprecated `/rest` endpoint can be reached over plain HTTP. The comment in the Dockerfile says it plainly: *"WARNING: THIS IS OBVIOUSLY INSECURE. NEVER DO THIS IN PRODUCTION."*

**Mitigation**: Remove the `COPY` and `sed` lines that install `rest_web.xml`, or block the `/rest` path at the Apache layer so it is never reachable externally.

### 2. AJP connector with `secretRequired="false"` (Ghostcat — CVE-2020-1938)
The AJP connector is configured with `secretRequired="false"`, which disables the shared-secret mitigation added in Tomcat 9.0.31+ in response to [Ghostcat (CVE-2020-1938, CVSS 9.8)](https://nvd.nist.gov/vuln/detail/CVE-2020-1938). Any host that can reach port 8009 can read arbitrary files from any deployed webapp (including config files with credentials) and potentially execute code if file-upload is available anywhere in the app.

The comment in the Dockerfile acknowledges the limitation: `secretRequired="true"` is not yet supported by `mod_proxy_ajp` in Apache 2.4.

**Mitigation (short-term)**: Ensure Kubernetes `NetworkPolicy` rules prevent all external traffic from reaching port 8009 — only the Apache sidecar/service should be able to connect to it.  
**Mitigation (long-term)**: Replace the AJP connector with an HTTP proxy (`mod_proxy_http` on port 8080), eliminating the AJP attack surface entirely.

### 3. Container runs as root
The final image stage has no `USER` directive, so Tomcat and all cron/admin scripts run as `root` inside the container. A successful RCE exploit or container-escape yields full root on the host node.

**Mitigation**: Create a dedicated `dspace` system user in the final stage and switch to it with `USER dspace` before the `EXPOSE` / `CMD` instructions (adjusting file ownership on `/dspace` and `/usr/local/tomcat` as needed).

### 4. Development and debug tools baked into the image
The following packages are installed in the production image but are not required for Tomcat or DSpace to run:

- `emacs`, `vim` — text editors
- `build-essential`, `ruby-dev` — compilers/headers (needed only to `gem install`; not needed at runtime)
- `pry` (Ruby gem) — interactive REPL/debugger
- `pipx` — Python package installer (only used once to install the AWS CLI)

These packages increase the attack surface and give an attacker a richer toolkit after gaining any foothold.

**Mitigation**: Move `gem install` to a separate build stage; remove `build-essential`, `ruby-dev`, and `pry` from the runtime image. Replace `pipx install awscli` with the pre-built AWS CLI v2 binary installer so `pipx` and `build-essential` are not needed at runtime.

### 5. AWS CLI baked into the image
The AWS CLI is installed unconditionally via `pipx install awscli`. If AWS credentials are available inside the container (e.g., via an EC2/EKS instance role or a mounted Secret), a compromised container gains direct access to AWS resources.

**Mitigation**: Verify whether the AWS CLI is actually needed at runtime. If it is only used by maintenance scripts run on demand, consider injecting it via an init container or a sidecar rather than baking it into the main image.

---

### port-forward database (workshop example)
Shell Terminal One
```shell
kubectl --namespace=workshop port-forward service/db 5432:5432
```
Shell Terminal Two
```shell
psql -h localhost -d dspace -U dspace
```
