#!/bin/sh
#
# script to run redis-cli in the docker-compose redis service
#

docker-compose exec redis redis-cli --askpass
