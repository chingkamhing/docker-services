#!/usr/bin/env bash
#
# MongoDB init script that create initial DB and user during first mongodb docker start up
#

#
# Note:
# - when MONGO_INITDB_ROOT_USERNAME is set and bootup the first mongodb, always have the following exception and fail to run init-mongo.sh
# - "uncaught exception: Error: couldn't add user: not master"
# - may not be able to create root user until the replica set is running and in master node
# - i.e. create root at the end of this script
#

# init mongodb replica set
echo "Init mongodb replica set..."
mongo --host localhost --port 27017 <<EOF
var config = {
    "_id": "rs0",
    "version": 1,
    "members": [
        {
            "_id": 1,
            "host": "db-mongo1:27017",
            "priority": 1
        },
        {
            "_id": 2,
            "host": "db-mongo2:27017",
            "priority": 0.5
        },
        {
            "_id": 3,
            "host": "db-mongo3:27017",
            "priority": 0.5
        }
    ]
};
rs.initiate(config, { force: true });
rs.status();
EOF

# create user permission
echo "Create user permission..."
if [ "$MY_DATABASE_NAME" ] && [ "$MY_DATABASE_USERNAME" ] && [ "$MY_DATABASE_PASSWORD" ]; then
    echo 'Creating application user and db for iTMS'
    mongo \
        --host localhost \
        --port 27017 \
        admin \
        --eval "db.getSiblingDB('${MY_DATABASE_NAME}').createUser({user: '${MY_DATABASE_USERNAME}', pwd: '${MY_DATABASE_PASSWORD}', roles:[{role:'dbOwner', db: '${MY_DATABASE_NAME}'}]});"
fi
