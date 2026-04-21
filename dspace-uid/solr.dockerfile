ARG SOURCE_IMAGE_TAG=umich
FROM ghcr.io/mlibrary/dspace-containerization/dspace-solr:${SOURCE_IMAGE_TAG}

ARG UID=1000950000

USER root

RUN deluser solr \
    && groupadd -g $UID solr \
    && useradd -g $UID -m -l -o -u $UID solr \
    && chown -R $UID:$UID /var/solr \
    && chown -R $UID:$UID /opt/solr

USER $UID

