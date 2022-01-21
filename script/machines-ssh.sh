#!/bin/bash
#
# Script file to ssh into docker machine (default: first machine of 'docker-machine ls').
#

OPTS=""
NUM_ARGS=0
DEBUG=""

# Function
SCRIPT_NAME=${0##*/}
Usage () {
	echo
	echo "Description:"
	echo "Script file to ssh into docker machine (default: first machine of 'docker-machine ls')."
	echo
	echo "Usage: $SCRIPT_NAME"
	echo "Options:"
	echo " -m  [machine name]           docker machine name (default: first machine of 'docker-machine ls')"
	echo " -h                           This help message"
	echo
	echo "Description:"
	echo "Script to invoke the command and arguments to the specified docker machine."
	echo
	echo "Usage: $SCRIPT_NAME [command] [args]..."
	echo "Options:"
	echo " -m  [machine name]           docker machine name (default: first machine of 'docker-machine ls')"
	echo " -h                           This help message"
	echo
}

IsIncludes () {
	local element=$1
	shift
	local array=($@)
	for a in ${array[@]}; do
		[ "$element" == "$a" ] && return 0
	done
	return 1
}

# Parse input argument(s)
while [ "${1:0:1}" == "-" ]; do
	OPT=${1:1:1}
	case "$OPT" in
	"m")
		MACHINE_NAME=$2
		shift
		;;
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

# get available docker machines
machines=$(docker-machine ls --format {{.Name}})
machines=(${machines[@]})

if [ "$MACHINE_NAME" == "" ]; then
	# default to use first docker machine
	MACHINE_NAME=${machines[0]}
else
	# check if the specified machine includes in docker machines
	IsIncludes $MACHINE_NAME ${machines[@]}
	if [ "$?" != "0" ]; then
		echo "Invalid docker machine name!"
		echo "Available docker machines:"
		for machine in ${machines[@]}; do
			echo "- $machine"
		done
		exit 1
	fi
fi

# parese input
ARGS=("$@")
NUM_ARGS="$#"

# ssh into docker-machine
if [ "$NUM_ARGS" -eq "0" ]; then
	# invoke the command and arguments to the specified docker machine
	echo "ssh into $MACHINE_NAME..."
	$DEBUG docker-machine ssh "$MACHINE_NAME"
else
	# ssh to the specified docker machine (default: first manager)
	$DEBUG docker-machine ssh "$MACHINE_NAME" "${ARGS[@]}"
fi
