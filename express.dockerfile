FROM node:23-bookworm

# FROM: This keyword is used in Dockerfiles to specify the base 
#   image you want to use to build your own new image. It is always 
#   the first instruction in a Dockerfile.
# node:23-bookworm: This is the name of the base image being used.
# node: This indicates the official Node.js image from Docker Hub.
# bookworm: This suggests that the image is built on top of the 
#   Debian "Bookworm" release. "Bookworm" is a codename for a version 
#   of the Debian operating system.

# Remember you have to put !/express in the .dockerignore file
# This file is needed in the dspace/epress.dockerfile
# The one here is used when running this on local machine.
# The dspace/express.dockerfile is used when running in the image.
# On local machine, you build with this command:
#   docker build -t express -f express.dockerfile .
# And you run:
#   docker run -p 3000:3000 express
# I needed to install: brew install tanka
# So I could check the jsonnet file: ???

# RUN apt update; \
#     apt install -y --no-install-recommends 

# Setting up the work directory in image
WORKDIR /express

# copy from local machine to the image.
COPY ./express/index.js /express/index.js

# These are needed in index.js
RUN npm install express
RUN npm install prom-client

# Exposing server port
EXPOSE 3000

# Starting our application: "node index.js"
CMD [ "node", "index.js" ]
