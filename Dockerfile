FROM openjdk:11

# Must match the version of the downloaded .zip file
ENV DATOMIC_VERSION 1.0.6269

RUN mkdir /datomic-bin
WORKDIR /datomic-bin
COPY downloads/datomic-pro-$DATOMIC_VERSION.zip start.sh /datomic-bin/
RUN unzip datomic-pro-$DATOMIC_VERSION.zip \
 && rm datomic-pro-$DATOMIC_VERSION.zip \
 && mv datomic-pro-$DATOMIC_VERSION datomic-pro \
 && chmod a+x start.sh \
 && mkdir /config \
 && mkdir /data \
 && apt update \
 && apt install -y netcat \
 && rm -rf /var/lib/apt/lists/*

# /config must contain
#   - dev-transactor.properties file for the transactor settings. This file must:
#        - use dev protocol
#        - listen on localhost on port 4334 (see start.sh)
#        - point data-dir to /data
#   - dbs-list file with a line for each db name to be used (will be created on startup if it doesnt exists)
# /data is for the data. Must be declared on transactor.properties

EXPOSE 8998 8080
CMD /datomic-bin/start.sh

