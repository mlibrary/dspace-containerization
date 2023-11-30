ARG SOURCE_IMAGE_TAG=umich
FROM ghcr.io/mlibrary/dspace-containerization/dspace-backend:${SOURCE_IMAGE_TAG}

ARG UID=1000950000

RUN apt-get update && \
    apt-get -y install --no-install-recommends \
      vim

RUN groupadd -g $UID dspace
RUN useradd -g $UID -m -l -o -u $UID dspace

RUN chown -R $UID:$UID /dspace
