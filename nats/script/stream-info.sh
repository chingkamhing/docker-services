#!/bin/bash
#
# Script file to list all nats stream.
#

URL="localhost:4222"
NATS_USERNAME=$MY_NATS_USERNAME
NATS_PASSWORD=$MY_NATS_PASSWORD
NUM_ARGS=0
OPTS=""
DEBUG=""

# Function
SCRIPT_NAME=${0##*/}
Usage () {
	echo
	echo "Description:"
	echo "Script file to list all nats stream."
	echo
	echo "Usage: $SCRIPT_NAME"
	echo "Options:"
	echo " -u  [url]                    NATS server URL"
	echo " -n  [username]               NATS login username"
	echo " -p  [password]               NATS login password"
	echo " -h                           This help message"
	echo
}

# Parse input argument(s)
while [ "${1:0:1}" == "-" ]; do
	OPT=${1:1:1}
	case "$OPT" in
	"u")
		URL=$2
		shift
		;;
	"n")
		NATS_USERNAME=$2
		shift
		;;
	"p")
		NATS_PASSWORD=$2
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

if [ "$URL" != "" ]; then
	OPTS="$OPTS --server $URL"
fi
if [ "$MY_NATS_USERNAME" != "" ]; then
	OPTS="$OPTS --user $MY_NATS_USERNAME"
fi
if [ "$MY_NATS_PASSWORD" != "" ]; then
	OPTS="$OPTS --password $MY_NATS_PASSWORD"
fi

# show stream summary
nats stream report $OPTS
nats stream ls $OPTS
streams_json=$(nats stream ls $OPTS --json)
if [ "$streams_json" != "null" ]; then
	# show individual stream detail
	streams=$(nats stream ls $OPTS --json | jq -r .[])
	while IFS= read -r stream; do
		nats stream info $OPTS $stream
	done <<< "$streams"
fi
