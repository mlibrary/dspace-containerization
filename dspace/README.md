# Building and running remotely (Kubernetes)

DSpace is hosted in the Library Information Technology (LIT) [Deepblue Documents Cluster](https://mlit.atlassian.net/l/cp/W410v0c7).
## build images
Run the GitHub action workflows in the following order to build the images that will be deployed to the library cluster.

| Workflow                                                                                                                     | Packages                                                                        |
|------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| [1. Build dspace source image](https://github.com/mlibrary/dspace-containerization/actions/workflows/build-source-image.yml) | dspace-source:`tag`                                                             |
| [2. Build dspace images](https://github.com/mlibrary/dspace-containerization/actions/workflows/build-dspace-images.yml)      | dspace-frontend:`tag`, dspace-backend:`tag`, dspace-solr:`tag`, dspace-db:`tag` |

NOTE: 
* The backend image contains `*.dspace.cfg.cpt` files in the `/dspace/config` directory that were copied from the `./backend/config` directory. These files were created by copying the `default.dspace.cfg` file and then making appropriate changes for the target environment. These files contain sensitive information and were encrypted using the `ccrypt` command. The keys to decrypt this files are held in Kubernetes secrets. 
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
To reach other services use the `kubectl --namespace=workshop port-forward service/<target> <port>:<port>` command.

| URL                                     | Container | Comments                                     |
|-----------------------------------------|-----------|----------------------------------------------|
| http://localhost:4000/home              | frontend  | Angular GUI                                  |
| jdbc:postgresql://localhost:5432/dspace | db        | PostgreSQL  (user: dspace, password: dspace) |
| http://localhost:8009/                  | backend   | debugging???                                 |
| http://localhost:8080/rest              | backend   | REST API (Deprecated)                        |
| http://localhost:8080/server            | backend   | Server API                                   |
| http://localhost:8888/                  | apache    | Apache Web Server                            |
| http://localhost:8983/solr              | solr      | Solr GUI                                     |
| http://localhost:9876/                  | frontend  | debugging???                                 |

### port-foward database (workshop example)
Shell Terminal One
```shell
kubectl --namespace=workshop port-forward service/db 5432:5432
```
Shell Terminal Two
```shell
psql -h localhost -d dspace -U dspace
```
