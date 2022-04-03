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

Prompt () {
	local prompt=$1
	if [ "$IS_PROMPT_PROCEED" == "yes" ]; then
		echo "Y"
		return
	fi
	local is_proceed
	echo -e "$prompt [Y/n]" > /dev/tty
	read is_proceed
	echo "$is_proceed"
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

# try find the running or exited container
CONTAINER=$(docker ps -a --filter name=${CONTAINER_NAME} --format {{.ID}})
if [ "$CONTAINER" != "" ]; then
	if [ "$(echo $CONTAINER | wc -w)" != "1" ]; then
		docker ps -a --filter name=${CONTAINER_NAME}
		is_proceed=$(Prompt "More than one containers are running, select the first one?")
		if [ "$is_proceed" != "Y" ]; then
			echo "Abort docker inspect."
			exit
		fi
		CONTAINER=$(echo $CONTAINER | head -n 1 | awk '{print $1;}')
	fi
	# inspect the specified container
	$DEBUG docker inspect $CONTAINER
	exit
fi

# try find the docker service list
# note: seems docker service filter search the name from start of word only
CONTAINER=$(docker service ls --filter name=${CONTAINER_NAME} --format {{.ID}})
if [ "$CONTAINER" != "" ]; then
	if [ "$(echo $CONTAINER | wc -w)" != "1" ]; then
		docker service ls --filter name=${CONTAINER_NAME}
		is_proceed=$(Prompt "More than one docker services are running, select the first one?")
		if [ "$is_proceed" != "Y" ]; then
			echo "Abort docker inspect."
			exit
		fi
		CONTAINER=$(echo $CONTAINER | head -n 1 | awk '{print $1;}')
	fi
	# inspect the specified container
	$DEBUG docker service ps $CONTAINER
	$DEBUG docker service inspect $CONTAINER
	exit
fi

echo "Container \"$CONTAINER_NAME\" is not running!"
exit 1
