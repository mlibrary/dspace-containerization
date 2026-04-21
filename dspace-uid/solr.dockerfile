ARG SOURCE_IMAGE_TAG=umich
FROM ghcr.io/mlibrary/dspace-containerization/dspace-solr:${SOURCE_IMAGE_TAG}

ARG UID=1000950000

USER root

RUN deluser solr
RUN groupadd -g $UID solr
RUN useradd -g $UID -m -l -o -u $UID solr

RUN chown -R $UID:$UID /var/solr
RUN chown -R $UID:$UID /opt/solr
