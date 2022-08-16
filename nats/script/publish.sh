#!/bin/bash
#
# Script file to publish to a nats subject.
#

URL="localhost:4222"
NATS_USERNAME=$MY_NATS_USERNAME
NATS_PASSWORD=$MY_NATS_PASSWORD
NUM_ARGS=2
OPTS=""
DEBUG=""

# Function
SCRIPT_NAME=${0##*/}
Usage () {
	echo
	echo "Description:"
	echo "Script file to publish to a nats subject."
	echo
	echo "Usage: $SCRIPT_NAME [subject] [message]"
	echo "Options:"
	echo " -c  [count]                  Repetitive publish count"
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
	"c")
		OPTS="$OPTS --count $2 --sleep 1s"
		REPETITIVE="yes"
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
if [ "$REPETITIVE" == "yes" ]; then
	MESSAGE="$2 {{Count}}"
else
	MESSAGE="$2"
fi

# publish to a nats subject
nats pub $OPTS $SUBJECT "$MESSAGE"
