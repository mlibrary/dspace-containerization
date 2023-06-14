ARG DSPACE_VERSION=7.5
FROM ghcr.io/mlibrary/dspace-containerization/dspace-backend:${DSPACE_VERSION}

ARG UID=1000950000

RUN apt-get update && \
    apt-get -y install --no-install-recommends \
      vim

RUN groupadd -g $UID dspace
RUN useradd -g $UID -m -l -o -u $UID dspace

RUN chown -R $UID:$UID /dspace
