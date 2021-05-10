#!/bin/sh

# Start transactor. Properties file must:
#  - use dev protocol
#  - listen on localhost on port $TRANSACTOR_PORT
TRANSACTOR_PORT=4334
/datomic-bin/datomic-pro/bin/transactor /config/dev-transactor.properties &

# Wait for transactor to start
while ! nc -z localhost $TRANSACTOR_PORT; do   
  sleep 1 # wait for 1 second before check again
done

# Ensure that the databases are created before starting peers.
# If database exists does nothing, else it creates database
DBSURIS_FOR_PEER=""
DBSURIS_FOR_CREATE=""
while IFS= read -r line; do
    if [ ! -z "$line" ]
    then
        DBSURIS_FOR_CREATE="$DBSURIS_FOR_CREATE \"datomic:dev://localhost:4334/$line\""
        DBSURIS_FOR_PEER="$DBSURIS_FOR_PEER -d $line,datomic:dev://localhost:4334/$line"
    fi
done < "/config/dbs-list"

# Use Datomic REPL to create databases
/datomic-bin/datomic-pro/bin/repl <<EOF
(require '[datomic.api :as d])
(dorun (map d/create-database '($DBSURIS_FOR_CREATE)))
EOF

echo Starting Datomic console on port 8080
/datomic-bin/datomic-pro/bin/console -p 8080 dev datomic:dev://localhost:4334 &

echo Starting Datomic peer on port 8998
/datomic-bin/datomic-pro/bin/run -m datomic.peer-server -h 0.0.0.0 -p 8998 -a myaccesskey,mysecret $DBSURIS_FOR_PEER
