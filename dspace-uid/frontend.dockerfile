ARG DSPACE_VERSION=7.5
FROM ghcr.io/mlibrary/dspace-containerization/dspace-frontend:${DSPACE_VERSION}

ARG UID=1000950000

RUN apk update && \
    apk add --no-cache \
    shadow \
    vim

RUN deluser node
RUN groupadd -g $UID node
RUN useradd -g $UID -m -l -o -u $UID node

RUN chown -R $UID:$UID /app
