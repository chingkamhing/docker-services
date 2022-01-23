#!/bin/bash
#
# Script file to list all docker machines.
#

OPTS=""
NUM_ARGS=0
DEBUG=""

# Function
SCRIPT_NAME=${0##*/}
Usage () {
	echo
	echo "Description:"
	echo "Script file to list all docker machines."
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

# list machine machines
machines=$(docker-machine ls --format {{.Name}})
for machine in ${machines[@]}; do
	echo "$machine:"
	echo "  IP:        $(docker-machine inspect $machine --format {{.Driver.IPAddress}})"
	echo "  CPU:       $(docker-machine inspect $machine --format {{.Driver.CPU}})"
	echo "  Memory:    $(docker-machine inspect $machine --format {{.Driver.Memory}})"
	echo "  Disk Size: $(docker-machine inspect $machine --format {{.Driver.DiskSize}})"
done
