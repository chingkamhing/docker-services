#!/bin/bash
#
# Reference:
# - https://docs.docker.com/config/containers/multi-service_container/
#

# turn on bash's job control
set -m

# start mongod as usual but in the background
mongod --replSet ${MY_MONOGO_REPLICA_SET_NAME} --keyFile /etc/mongodb.keyfile --bind_ip 0.0.0.0 --port 27017 --dbpath /data/db --timeZoneInfo /usr/share/zoneinfo &

# start init-replica-set.sh to initialize mongodb replica set
/root/init-replica-set.sh

# now we bring the primary process back into the foreground and leave it there
fg %1
