#!/usr/bin/env bash
#
# MongoDB init script that create initial DB and user during first mongodb docker start up
#

#
# Note:
# - "uncaught exception: Error: couldn't add user: not master"
#   - when MONGO_INITDB_ROOT_USERNAME is set and bootup the first mongodb, always have the above exception and fail to run init-mongo.sh
#   - which suggest root user cannot be created until the replica set is running and in master node
#   - i.e. create root and/or other users at the end of this script
# - believe the parent shell "set -e" that exit this script upon any error
#

mongo_servers=(
    "db-mongo1"
    "db-mongo2"
    "db-mongo3"
)
wait_count=10
wait_interval=6s

WaitMongosReady() {
	local servers=$*
	for server in ${servers[@]}; do
        echo "Wait for mongo server \"$server\" be ready..."
        WaitMongoReady $server
        if [ "$?" != "0" ]; then
            echo "Fail to connect to server \"$server\", abort init mongo."
            exit 1
        else
            echo "Server \"$server\" is ready."
        fi
	done
}

WaitMongoReady() {
	local server=$1
	for (( i=1; i<=$wait_count; i++ )); do
        mongo --host $server --port 27017 --eval "db.runCommand( { ping: 1 } )" &>/dev/null
        [ "$?" == "0" ] && return 0
        sleep $wait_interval
	done
    return 1
}

# init mongodb replica set
echo "------------------------------------------------------------"
echo "Ping mongo servers..."
WaitMongosReady ${mongo_servers[*]}

echo "------------------------------------------------------------"
echo "Init mongodb replica set..."
mongo --host localhost --port 27017 <<EOF
var config = {
    "_id": "$MY_MONOGO_REPLICA_SET_NAME",
    "version": 1,
    "members": [
        {
            "_id": 1,
            "host": "db-mongo1:27017",
            "priority": 2
        },
        {
            "_id": 2,
            "host": "db-mongo2:27017",
            "priority": 1
        },
        {
            "_id": 3,
            "host": "db-mongo3:27017",
            "priority": 1
        }
    ]
};
rs.initiate(config, { force: true });
EOF

# wait a while to settle the primary node
sleep 15s

# create admin
mongo --host localhost --port 27017 <<EOF
use admin;
admin = db.getSiblingDB("admin");
admin.createUser({
    user: "${MY_INITDB_ROOT_USERNAME}",
    pwd: "${MY_INITDB_ROOT_PASSWORD}",
    roles: [ { role: "root", db: "admin" } ]
});
db.getSiblingDB("admin").auth("${MY_INITDB_ROOT_USERNAME}", "${MY_INITDB_ROOT_PASSWORD}");
rs.status();
EOF
