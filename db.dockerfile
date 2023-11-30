# This Dockerfile uses 7.6 by default
# To build with 7_x, use "--build-arg DSPACE_VERSION=7_x"
ARG DSPACE_VERSION=7.6
FROM dspace/dspace-postgres-pgcrypto:dspace-${DSPACE_VERSION}
