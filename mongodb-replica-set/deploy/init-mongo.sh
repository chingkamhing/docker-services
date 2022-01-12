#!/usr/bin/env bash
#
# MongoDB init script that create initial DB and user during first mongodb docker start up
#

# init mongodb replica set
echo "Init mongodb replica set..."
echo "MONGO_INITDB_ROOT_USERNAME: ${MONGO_INITDB_ROOT_USERNAME}"
sleep 5s
mongo --host localhost --port 27017 -u ${MONGO_INITDB_ROOT_USERNAME} -p ${MONGO_INITDB_ROOT_PASSWORD} <<EOF
var config = {
    "_id": "rs0",
    "version": 1,
    "members": [
        {
            "_id": 1,
            "host": "db-mongo1:27017",
            "priority": 3
        },
        {
            "_id": 2,
            "host": "db-mongo2:27017",
            "priority": 2
        },
        {
            "_id": 3,
            "host": "db-mongo3:27017",
            "priority": 1
        }
    ]
};
rs.initiate(config, { force: true });
rs.status();
EOF

# create user permission
echo "Create user permission..."
sleep 5s
if [ "$ITMS_DATABASE_NAME" ] && [ "$ITMS_DATABASE_USERNAME" ] && [ "$ITMS_DATABASE_PASSWORD" ]; then
    echo 'Creating application user and db for iTMS'
    mongo \
        --host localhost \
        --port 27017 \
        -u ${MONGO_INITDB_ROOT_USERNAME} \
        -p ${MONGO_INITDB_ROOT_PASSWORD} \
        admin \
        --eval "db.getSiblingDB('${ITMS_DATABASE_NAME}').createUser({user: '${ITMS_DATABASE_USERNAME}', pwd: '${ITMS_DATABASE_PASSWORD}', roles:[{role:'dbOwner', db: '${ITMS_DATABASE_NAME}'}]});"
fi
