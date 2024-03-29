#!/bin/bash
#
# Script file to subscribe to a nats subject. If queue group is specified, act as queue; if queue is not specified, act as pubsub.
#

URL="localhost:4222"
NATS_USERNAME=$MY_NATS_USERNAME
NATS_PASSWORD=$MY_NATS_PASSWORD
NUM_ARGS=1
OPTS=""
DEBUG=""

# Function
SCRIPT_NAME=${0##*/}
Usage () {
	echo
	echo "Description:"
	echo "Script file to subscribe to a nats subject. If queue group is specified, act as queue; if queue is not specified, act as pubsub."
	echo
	echo "Usage: $SCRIPT_NAME [subject]"
	echo "Options:"
	echo " -q  [queue]                  NATS queue group"
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
	"q")
		OPTS="$OPTS --queue $2"
		shift
		;;
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

SUBJECT=$1

# subscribe to a nats subject
nats sub $OPTS $SUBJECT
