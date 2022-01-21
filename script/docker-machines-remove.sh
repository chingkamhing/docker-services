#!/bin/bash
#
# Script file to remove all docker machines.
#

OPTS=""
NUM_ARGS=0
DEBUG=""

# Function
SCRIPT_NAME=${0##*/}
Usage () {
	echo
	echo "Description:"
	echo "Script file to remove all docker machines."
	echo
	echo "Usage: $SCRIPT_NAME"
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

if [ "$#" -ne "$NUM_ARGS" ]; then
	echo "Invalid parameter!"
	Usage
	exit 1
fi

machines=$(docker-machine ls --format {{.Name}})
machines=$(echo ${machines[@]})
is_proceed=$(Prompt "Confirm to remove docker machines ${machines[@]}?")
if [ "$is_proceed" != "Y" ]; then
	echo "Abort removing docker machine."
	exit
fi

# stop and remove machine machines
$DEBUG docker-machine stop ${machines[@]}
$DEBUG docker-machine remove ${machines[@]}
