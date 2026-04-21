FROM ubuntu:22.04

ARG GITHUB_BRANCH=umich

RUN apt-get update && \
    apt-get -y -o Acquire::Retries=3 install --no-install-recommends \
      ca-certificates \
      git \
    && rm -rf /var/lib/apt/lists/*

ENV GITHUB_BRANCH=${GITHUB_BRANCH}

RUN git clone --depth 1 --branch ${GITHUB_BRANCH} https://github.com/mlibrary/dspace.git /DSpace

RUN git clone --depth 1 --branch ${GITHUB_BRANCH} https://github.com/mlibrary/dspace-angular.git /dspace-angular
