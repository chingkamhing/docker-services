#!/bin/bash
#
# Script file print mongo server status.
#

CONTAINER_NAME="mongo1"
CMD="\"hello\""
NUM_ARGS=0
OPTS=""
DEBUG=""

# Function
SCRIPT_NAME=${0##*/}
Usage () {
	echo
	echo "Description:"
	echo "Script file print mongo server status."
	echo
	echo "Usage: $SCRIPT_NAME"
	echo "Options:"
	echo " -c  [container]              Mongo container name (default: $CONTAINER_NAME)"
	echo " -u  [username]               Mongodb login username"
	echo " -p  [password]               Mongodb login password"
	echo " -h                           This help message"
	echo
}

# Parse input argument(s)
while [ "${1:0:1}" == "-" ]; do
	OPT=${1:1:1}
	case "$OPT" in
	"c")
		CONTAINER_NAME=$2
		shift
		;;
	"u")
		OPTS="$OPTS -u $2"
		shift
		;;
	"p")
		OPTS="$OPTS -p $2"
		shift
		;;
	"h")
		Usage
		exit
		;;
	esac
	shift
done

if [ "$#" -ne "$NUM_ARGS" ]; then
    echo "Invalid parameter!"
	Usage
	exit 1
fi

CONTAINER=$(docker ps --filter name=${CONTAINER_NAME} --format {{.ID}})
if [ "$CONTAINER" == "" ]; then
	echo "Container \"${CONTAINER_NAME}\" not found!"
	echo "Posible mongo container:"
	docker ps --filter name=mongo
	exit 1
fi
if [ "$(echo $CONTAINER | wc -w)" != "1" ]; then
	echo "More than one container are found, please specify:"
	docker ps --filter name=${CONTAINER_NAME}
	exit 1
fi

# docker exec to the container
$DEBUG docker exec -it $CONTAINER mongo --quiet $OPTS --eval "db.runCommand( $CMD )"
