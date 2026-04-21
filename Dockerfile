FROM ubuntu:20.04

ARG GITHUB_BRANCH=umich

RUN apt-get update && \
    apt-get -y install --no-install-recommends \
      ca-certificates \
      git \
      wget \
      unzip

ENV GITHUB_BRANCH=${GITHUB_BRANCH}

RUN wget -q https://github.com/mlibrary/dspace/archive/refs/heads/${GITHUB_BRANCH}.zip && \
    unzip -q /${GITHUB_BRANCH}.zip -d / && \
    rm -rf /${GITHUB_BRANCH}.zip && \
    mv /DSpace-${GITHUB_BRANCH} /DSpace

RUN wget -q https://github.com/mlibrary/dspace-angular/archive/refs/heads/${GITHUB_BRANCH}.zip && \
    unzip -q /${GITHUB_BRANCH}.zip -d / && \
    rm -rf /${GITHUB_BRANCH}.zip && \
    mv /dspace-angular-${GITHUB_BRANCH} /dspace-angular
