ARG DSPACE_VERSION=7.6
FROM ghcr.io/mlibrary/dspace-containerization/dspace-db:${DSPACE_VERSION}

ARG UID=1000950000

RUN deluser postgres
RUN groupadd -g $UID postgres
RUN useradd -g $UID -m -l -o -u $UID postgres

RUN chown -R $UID:$UID /var/run/postgresql
RUN chown -R $UID:$UID /var/lib/postgresql
