FROM ubuntu:20.04

ARG BACKEND_GITHUB_USER=mlibrary
ARG BACKEND_GITHUB_REPO=dspace
ARG BACKEND_GITHUB_BRANCH=cgi

ARG FRONTEND_GITHUB_USER=mlibrary
ARG FRONTEND_GITHUB_REPO=dspace-angular
ARG FRONTEND_GITHUB_BRANCH=cgi

RUN apt-get update && \
    apt-get -y install --no-install-recommends \
      ca-certificates \
      git \
      wget \
      unzip

ENV BACKEND_GITHUB_USER=${BACKEND_GITHUB_USER}
ENV BACKEND_GITHUB_REPO=${BACKEND_GITHUB_REPO}
ENV BACKEND_GITHUB_BRANCH=${BACKEND_GITHUB_BRANCH}
RUN wget -q https://github.com/${BACKEND_GITHUB_USER}/${BACKEND_GITHUB_REPO}/archive/refs/heads/${BACKEND_GITHUB_BRANCH}.zip && \
    unzip -q /${BACKEND_GITHUB_BRANCH}.zip -d / && \
    rm -rf /${BACKEND_GITHUB_BRANCH}.zip && \
    mv /DSpace-${BACKEND_GITHUB_BRANCH} /DSpace

ENV FRONTEND_GITHUB_USER=${FRONTEND_GITHUB_USER}
ENV FRONTEND_GITHUB_REPO=${FRONTEND_GITHUB_REPO}
ENV FRONTEND_GITHUB_BRANCH=${FRONTEND_GITHUB_BRANCH}
RUN wget -q https://github.com/${FRONTEND_GITHUB_USER}/${FRONTEND_GITHUB_REPO}/archive/refs/heads/${FRONTEND_GITHUB_BRANCH}.zip && \
    unzip -q /${FRONTEND_GITHUB_BRANCH}.zip -d / && \
    rm -rf /${FRONTEND_GITHUB_BRANCH}.zip && \
    mv /dspace-angular-${FRONTEND_GITHUB_BRANCH} /dspace-angular
