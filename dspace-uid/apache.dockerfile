ARG REF_NAME=main
FROM ghcr.io/mlibrary/dspace-containerization/dspace-apache:${REF_NAME}

ARG UID=1000950000

RUN apt-get update && \
    apt-get -y install --no-install-recommends \
      vim

RUN groupadd -g $UID apache
RUN useradd -g $UID -m -l -o -u $UID apache

RUN chown -R $UID:$UID /usr/local/apache2
