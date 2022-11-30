#!/bin/sh
#
# script to run mysql-cli in the docker-compose mysql service
#

docker-compose exec mysql mysql --user=$DATABASE_USER --password=$DATABASE_PASSWORD -h localhost $DATABASE_DBNAME