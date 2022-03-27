#!/bin/bash
#
# Script file to list all nats consumer.
#

URL="localhost:4222"
NATS_USERNAME=$NATS_USERNAME
NATS_PASSWORD=$NATS_PASSWORD
NUM_ARGS=0
OPTS=""
DEBUG=""

# Function
SCRIPT_NAME=${0##*/}
Usage () {
	echo
	echo "Description:"
	echo "Script file to list all nats consumer."
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
if [ "$NATS_USERNAME" != "" ]; then
	OPTS="$OPTS --user $NATS_USERNAME"
fi
if [ "$NATS_PASSWORD" != "" ]; then
	OPTS="$OPTS --password $NATS_PASSWORD"
fi

streams_json=$(nats stream ls $OPTS --json)
if [ "$streams_json" != "null" ]; then
	# show individual stream's consumer detail
	streams=$(nats stream ls $OPTS --json | jq -r .[])
	while IFS= read -r stream; do
		# show consumer summary
		nats consumer report $OPTS $stream
		nats consumer ls $OPTS $stream
		# show consumer detail
		consumers=$(nats consumer ls $OPTS $stream --json | jq -r .[])
		while IFS= read -r consumer; do
			nats consumer info $OPTS $stream $consumer
		done <<< "$consumers"
	done <<< "$streams"
else
	echo "No Streams defined"
fi
