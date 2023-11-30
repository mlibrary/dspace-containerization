ARG SOURCE_IMAGE_TAG=umich
FROM ghcr.io/mlibrary/dspace-containerization/dspace-frontend:${SOURCE_IMAGE_TAG}

ARG UID=1000950000

RUN apk update && \
    apk add --no-cache \
    shadow \
    vim

RUN deluser node
RUN groupadd -g $UID node
RUN useradd -g $UID -M -l -o -u $UID node

RUN chown -R $UID:$UID /home/node
RUN chown -R $UID:$UID /app
