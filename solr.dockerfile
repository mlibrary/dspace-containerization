FROM dspace-containerization-source as source

FROM solr:8.11-slim

COPY --from=source /DSpace/dspace/solr/authority /opt/solr/server/solr/configsets/authority
COPY --from=source /DSpace/dspace/solr/oai /opt/solr/server/solr/configsets/oai
COPY --from=source /DSpace/dspace/solr/search /opt/solr/server/solr/configsets/search
COPY --from=source /DSpace/dspace/solr/statistics /opt/solr/server/solr/configsets/statistics
