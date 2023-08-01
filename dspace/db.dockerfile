ARG DSPACE_VERSION=7_x
ARG SOURCE_IMAGE_TAG=demo
FROM dspace/dspace-postgres-pgcrypto:dspace-${DSPACE_VERSION}
