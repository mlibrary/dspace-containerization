ARG SOURCE_IMAGE_TAG=umich
FROM ghcr.io/mlibrary/dspace-containerization/dspace-source:${SOURCE_IMAGE_TAG} as source

FROM node:18-alpine
WORKDIR /app
COPY --from=source /dspace-angular /app/
EXPOSE 4000

# Ensure Python and other build tools are available
# These are needed to install some node modules, especially on linux/arm64
RUN apk add --update python3 make g++ curl && rm -rf /var/cache/apk/*

# We run yarn install with an increased network timeout (5min) to avoid "ESOCKETTIMEDOUT" errors from hub.docker.com
# See, for example https://github.com/yarnpkg/yarn/issues/5540
RUN yarn install --network-timeout 600000

#RUN  yarn build:prod
RUN yarn build:ssr

# On startup, run in DEVELOPMENT mode (this defaults to live reloading enabled, etc).
# Listen / accept connections from all IP addresses.
# NOTE: At this time it is only possible to run Docker container in Production mode
# if you have a public IP. See https://github.com/DSpace/dspace-angular/issues/1485
#CMD yarn serve:ssr --disable-host-check --host 0.0.0.0
CMD node dist/server/main.js