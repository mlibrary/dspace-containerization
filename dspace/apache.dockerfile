FROM httpd:2.4-bookworm

RUN apt update; \
    apt install -y --no-install-recommends \
        libcgi-pm-perl \
        libdbi-perl \
        libdbd-pg-perl

COPY ./apache2/conf/httpd.conf /usr/local/apache2/conf/httpd.conf
COPY ./apache2/cgi-bin/ /usr/local/apache2/cgi-bin/
COPY ./apache2/htdocs/ /usr/local/apache2/htdocs/
