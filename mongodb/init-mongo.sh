#!/usr/bin/env bash
#
# MongoDB init script that create initial DB and user during first mongodb docker start up
#

if [ "$IMS_SECURITY_SERVICE_APIGATEWAY_DATABASE_DBNAME" ] && [ "$IMS_SECURITY_SERVICE_APIGATEWAY_DATABASE_USER" ] && [ "$IMS_SECURITY_SERVICE_APIGATEWAY_DATABASE_PASSWORD" ]; then
    echo 'Creating application user and db for authen service'
    mongo \
        --host localhost \
        --port 27017 \
        -u ${MONGO_INITDB_ROOT_USERNAME} \
        -p ${MONGO_INITDB_ROOT_PASSWORD} \
        admin \
        --eval "db.getSiblingDB('${IMS_SECURITY_SERVICE_APIGATEWAY_DATABASE_DBNAME}').createUser({user: '${IMS_SECURITY_SERVICE_APIGATEWAY_DATABASE_USER}', pwd: '${IMS_SECURITY_SERVICE_APIGATEWAY_DATABASE_PASSWORD}', roles:[{role:'dbOwner', db: '${IMS_SECURITY_SERVICE_APIGATEWAY_DATABASE_DBNAME}'}]});"
fi

if [ "$IMS_SECURITY_SERVICE_AUTHEN_DATABASE_DBNAME" ] && [ "$IMS_SECURITY_SERVICE_AUTHEN_DATABASE_USER" ] && [ "$IMS_SECURITY_SERVICE_AUTHEN_DATABASE_PASSWORD" ]; then
    echo 'Creating application user and db for authen service'
    mongo \
        --host localhost \
        --port 27017 \
        -u ${MONGO_INITDB_ROOT_USERNAME} \
        -p ${MONGO_INITDB_ROOT_PASSWORD} \
        admin \
        --eval "db.getSiblingDB('${IMS_SECURITY_SERVICE_AUTHEN_DATABASE_DBNAME}').createUser({user: '${IMS_SECURITY_SERVICE_AUTHEN_DATABASE_USER}', pwd: '${IMS_SECURITY_SERVICE_AUTHEN_DATABASE_PASSWORD}', roles:[{role:'dbOwner', db: '${IMS_SECURITY_SERVICE_AUTHEN_DATABASE_DBNAME}'}]});"
fi

if [ "$IMS_SECURITY_SERVICE_USER_DATABASE_DBNAME" ] && [ "$IMS_SECURITY_SERVICE_USER_DATABASE_USER" ] && [ "$IMS_SECURITY_SERVICE_USER_DATABASE_PASSWORD" ]; then
    echo 'Creating application user and db for user service'
    mongo \
        --host localhost \
        --port 27017 \
        -u ${MONGO_INITDB_ROOT_USERNAME} \
        -p ${MONGO_INITDB_ROOT_PASSWORD} \
        admin \
        --eval "db.getSiblingDB('${IMS_SECURITY_SERVICE_USER_DATABASE_DBNAME}').createUser({user: '${IMS_SECURITY_SERVICE_USER_DATABASE_USER}', pwd: '${IMS_SECURITY_SERVICE_USER_DATABASE_PASSWORD}', roles:[{role:'dbOwner', db: '${IMS_SECURITY_SERVICE_USER_DATABASE_DBNAME}'}]});"
fi
