#!/bin/bash
#
# Script file to create virtualbox or generic docker machines.
#

PREFIX="node"
DRIVER="virtualbox"
SSH_KEY_FILE="$HOME/.ssh/id_rsa"
SSH_USENAME="root"
OPTS=""
NUM_ARGS=1
DEBUG=""

# Function
SCRIPT_NAME=${0##*/}
Usage () {
	echo
	echo "Description:"
	echo "Script file to create virtualbox or generic docker machines."
	echo
	echo "Usage:"
	echo "- virtualbox: $SCRIPT_NAME [num virtual machines]"
	echo "- generic:    $SCRIPT_NAME [host ip address...]"
	echo "Options:"
	echo " -u  [username]               If generic driver, username for the hosts"
	echo " -p  [machine prefix]         docker machine name prefix (default: $PREFIX; will append with sequence number of machines)"
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

IsIP() {
	[[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && return 0 || return 1
}

GenerateSshKey() {
    if [ ! -f $SSH_KEY_FILE ]; then
		echo "======> Generate ssh key."
        ssh-keygen
	else
		echo "======> Already have ssh key."
    fi
}

# Parse input argument(s)
while [ "${1:0:1}" == "-" ]; do
	OPT=${1:1:1}
	case "$OPT" in
	"u")
		SSH_USENAME=$2
		shift
		;;
	"p")
		PREFIX=$2
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

# parse parameters
if [[ $1 =~ ^[0-9]+$ ]]; then
	DRIVER="virtualbox"
	NUM_NODES=$1
	prompt="Confirm to create $NUM_NODES virtualbox docker machines with prefix \"$PREFIX\"?"
else
	DRIVER="generic"
	NUM_NODES=$#
	HOSTS=($@)
	for host in ${HOSTS[@]}; do
		echo "host: $host"
		IsIP $host
		if [ "$?" -ne "0" ]; then
			echo "Invalid ip address parameter!"
			Usage
			exit 1
		fi
	done
	prompt="Confirm to create $NUM_NODES generic docker machines with hosts of ${HOSTS[@]} and prefix \"$PREFIX\"?"
fi

is_proceed=$(Prompt "$prompt")
if [ "$is_proceed" != "Y" ]; then
	echo "Abort creating docker machine."
	exit
fi

# generate ssh key
GenerateSshKey

# create machine machines
echo "======> Creating $NUM_NODES machine machines...";
for num in $(seq 1 $NUM_NODES); do
	index=$(( num - 1 ))
	echo "======> Creating ${PREFIX}${num} machine...";
	case "$DRIVER" in
	"virtualbox")
		driver_string="-d virtualbox"
		;;
	"generic")
		host="${HOSTS[$index]}"
		driver_string="-d generic --generic-ip-address $host --generic-ssh-key $SSH_KEY_FILE --generic-ssh-user $SSH_USENAME"
		;;
	esac
	$DEBUG docker-machine create $driver_string ${PREFIX}${num};
done
