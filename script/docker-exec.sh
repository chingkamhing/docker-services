#!/bin/bash
#
# Script file to docker exec (default command "sh") a running container with the specify name.
#

OPTS=""
DEBUG=""
NUM_ARGS=1

# Function
SCRIPT_NAME=${0##*/}
Usage () {
	echo
	echo "Description:"
	echo "Script file to docker exec (default command \"sh\") a running container with the specify name."
	echo
	echo "e.g."
	echo "$SCRIPT_NAME container"
	echo
	echo "Usage: $SCRIPT_NAME [conatainer name] [...command and arguments]"
	echo "Options:"
	echo " -h                           This help message"
	echo
}

# Parse input argument(s)
while [ "${1:0:1}" == "-" ]; do
	OPT=${1:1:1}
	case "$OPT" in
	"h")
		Usage
		exit
		;;
	esac
	shift
done

if [ "$#" -lt "$NUM_ARGS" ]; then
    echo "Invalid parameter!"
	Usage
	exit 1
fi

# first argument is the container name
CONTAINER_NAME=$1
# the rest of arguments will be passed to the container
shift
CMD=$*

# find the container
CONTAINER=$(docker ps --filter name=${CONTAINER_NAME} --format {{.ID}})
if [ "$CONTAINER" == "" ]; then
	echo "Container \"$CONTAINER_NAME\" is not running!"
	exit 1
fi
if [ "$(echo $CONTAINER | wc -w)" != "1" ]; then
	echo "More than one containers are running, please specify which one:"
	docker ps --filter name=${CONTAINER_NAME}
	exit 1
fi

# exec the specified container
if [ "$CMD" == "" ]; then
	CMD="sh"
fi
$DEBUG docker exec -it $CONTAINER $CMD
