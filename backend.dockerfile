# This Dockerfile uses 7.6 by default
# To build with 7_x, use "--build-arg DSPACE_VERSION=7_x"
ARG DSPACE_VERSION=7.6

# This Dockerfile uses JDK11 by default, but has also been tested with JDK17.
# To build with JDK17, use "--build-arg JDK_VERSION=17"
ARG JDK_VERSION=11

FROM dspace-containerization-source as source

# Step 1 - Run Maven Build
FROM dspace/dspace-dependencies:dspace-${DSPACE_VERSION} as mvn_build
ARG TARGET_DIR=dspace-installer

WORKDIR /app

# Copy the DSpace source code into the workdir
COPY --from=source --chown=dspace /DSpace /app

# The dspace-installer directory will be written to /install
RUN mkdir /install && chown -Rv dspace: /install

USER dspace

# Build DSpace (INCLUDING the optional, deprecated "dspace-rest" webapp)
# Copy the dspace-installer directory to /install.  Clean up the build to keep the docker image small
RUN mvn --no-transfer-progress package -Pdspace-rest && \
  mv /app/dspace/target/${TARGET_DIR}/* /install && \
  mvn clean

# Step 2 - Run Ant Deploy
FROM openjdk:${JDK_VERSION}-slim as ant_build
ARG TARGET_DIR=dspace-installer
# COPY the /install directory from 'build' container to /dspace-src in this container
COPY --from=mvn_build /install /dspace-src
WORKDIR /dspace-src
# Create the initial install deployment using ANT
ENV ANT_VERSION 1.10.12
ENV ANT_HOME /tmp/ant-$ANT_VERSION
ENV PATH $ANT_HOME/bin:$PATH
# Need wget to install ant
RUN apt-get update \
    && apt-get install -y --no-install-recommends wget \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/*
# Download and install 'ant'
RUN mkdir $ANT_HOME && \
    wget -qO- "https://archive.apache.org/dist/ant/binaries/apache-ant-$ANT_VERSION-bin.tar.gz" | tar -zx --strip-components=1 -C $ANT_HOME
# Run necessary 'ant' deploy scripts
RUN ant init_installation update_configs update_code update_webapps

# Step 3 - Run tomcat
# Create a new tomcat image that does not retain the the build directory contents
FROM tomcat:9-jdk${JDK_VERSION}
ENV DSPACE_INSTALL=/dspace
ENV TOMCAT_INSTALL=/usr/local/tomcat
# Copy the /dspace directory from 'ant_build' containger to /dspace in this container
COPY --from=ant_build /dspace $DSPACE_INSTALL

# Install additional libraries needed for backend scripts
RUN apt update; \
    apt install -y --no-install-recommends \
        ccrypt \
        libcgi-pm-perl \
        libdbi-perl \
        libio-all-lwp-perl \
        liberror-perl \
        libdbd-pg-perl \
        libjson-xs-perl \
        libemail-sender-perl \
        libemail-mime-perl \
        libemail-stuffer-perl \
        libmime-lite-perl \
        libnet-sftp-foreign-perl \
        libmailtools-perl \
        unzip \
        xsltproc \
        dnsutils \
        emacs \
        vim \
        build-essential  \
        ruby-dev \
        pipx \
        iputils-ping \
        mailutils

RUN gem install uri pry net-http json
RUN pipx install awscli
RUN ln -s /mnt/assetstore/dspace/repository/dev-test/asset_jose /dspace/assetstore

RUN mkdir /root/.emacs.d
# Install additional backend scripts
COPY ./backend/init.el /root/.emacs.d/init.el
COPY ./backend/bin/ $DSPACE_INSTALL/bin/
COPY ./backend/logs/ $DSPACE_INSTALL/logs/

# Enable the AJP connector in Tomcat's server.xml
# NOTE: secretRequired="false" should only be used when AJP is NOT accessible from an external network. But, secretRequired="true" isn't supported by mod_proxy_ajp until Apache 2.5
RUN sed -i '/Service name="Catalina".*/a \\n    <Connector protocol="AJP/1.3" port="8009" address="0.0.0.0" redirectPort="8443" URIEncoding="UTF-8" secretRequired="false" />' $TOMCAT_INSTALL/conf/server.xml
# Expose Tomcat port and AJP port
EXPOSE 8080 8009
# Give java extra memory (2GB)
ENV JAVA_OPTS=-Xmx2000m
# Set up debugging
ENV CATALINA_OPTS=-Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=*:8000

# Link the DSpace 'server' webapp into Tomcat's webapps directory.
# This ensures that when we start Tomcat, it runs from /server path (e.g. http://localhost:8080/server/)
# Also link the v6.x (deprecated) REST API off the "/rest" path
RUN ln -s $DSPACE_INSTALL/webapps/server   /usr/local/tomcat/webapps/server   && \
    ln -s $DSPACE_INSTALL/webapps/rest          /usr/local/tomcat/webapps/rest
# If you wish to run "server" webapp off the ROOT path, then comment out the above RUN, and uncomment the below RUN.
# You also MUST update the 'dspace.server.url' configuration to match.
# Please note that server webapp should only run on one path at a time.
#RUN mv /usr/local/tomcat/webapps/ROOT /usr/local/tomcat/webapps/ROOT.bk && \
#    ln -s $DSPACE_INSTALL/webapps/server   /usr/local/tomcat/webapps/ROOT && \
#    ln -s $DSPACE_INSTALL/webapps/rest          /usr/local/tomcat/webapps/rest

# Overwrite the v6.x (deprecated) REST API's web.xml, so that we can run it on HTTP (defaults to requiring HTTPS)
# WARNING: THIS IS OBVIOUSLY INSECURE. NEVER DO THIS IN PRODUCTION.
COPY --from=source /DSpace/dspace/src/main/docker/test/rest_web.xml $DSPACE_INSTALL/webapps/rest/WEB-INF/web.xml
RUN sed -i -e "s|\${dspace.dir}|$DSPACE_INSTALL|" $DSPACE_INSTALL/webapps/rest/WEB-INF/web.xml
