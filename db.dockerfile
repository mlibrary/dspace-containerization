# This Dockerfile uses 7_x by default
# To build with 7.6, use "--build-arg DSPACE_VERSION=7.6"
ARG DSPACE_VERSION=7_x
FROM dspace/dspace-postgres-pgcrypto:dspace-${DSPACE_VERSION}
