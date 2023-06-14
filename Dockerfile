FROM ubuntu:20.04

ARG BACKEND_GITHUB_USER=DSpace
ARG BACKEND_GITHUB_REPO=dspace
ARG BACKEND_GITHUB_TAG=7.5

ARG FRONTEND_GITHUB_USER=DSpace
ARG FRONTEND_GITHUB_REPO=dspace-angular
ARG FRONTEND_GITHUB_TAG=7.5

ARG DSPACE_VERSION=7.5
ENV DSPACE_VERSION=${DSPACE_VERSION}

RUN apt-get update && \
    apt-get -y install --no-install-recommends \
      ca-certificates \
      git \
      wget \
      unzip

ENV BACKEND_GITHUB_USER=${BACKEND_GITHUB_USER}
ENV BACKEND_GITHUB_REPO=${BACKEND_GITHUB_REPO}
ENV BACKEND_GITHUB_TAG=${BACKEND_GITHUB_TAG}
RUN wget -q https://github.com/${BACKEND_GITHUB_USER}/${BACKEND_GITHUB_REPO}/archive/refs/tags/dspace-${BACKEND_GITHUB_TAG}.zip && \
    unzip -q /dspace-$DSPACE_VERSION.zip -d / && \
    rm -rf /dspace-$DSPACE_VERSION.zip && \
    mv /DSpace-dspace-$DSPACE_VERSION /DSpace

ENV FRONTEND_GITHUB_USER=${FRONTEND_GITHUB_USER}
ENV FRONTEND_GITHUB_REPO=${FRONTEND_GITHUB_REPO}
ENV FRONTEND_GITHUB_TAG=${FRONTEND_GITHUB_TAG}
RUN wget -q https://github.com/DSpace/dspace-angular/archive/refs/tags/dspace-$DSPACE_VERSION.zip && \
    unzip -q /dspace-$DSPACE_VERSION.zip -d / && \
    rm -rf /dspace-$DSPACE_VERSION.zip && \
    mv /dspace-angular-dspace-$DSPACE_VERSION /dspace-angular
