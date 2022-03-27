#!/bin/bash
#
# Script file to create a log consumer that is push-based, instant replay and no ack.
#

URL="localhost:4222"
NATS_USERNAME=$NATS_USERNAME
NATS_PASSWORD=$NATS_PASSWORD
NUM_ARGS=2
OPTS=""
DEBUG=""

# Function
SCRIPT_NAME=${0##*/}
Usage () {
	echo
	echo "Description:"
	echo "Script file to create a log consumer that is push-based, instant replay and no ack."
	echo
	echo "Usage: $SCRIPT_NAME [stream name] [consumer name]"
	echo "Options:"
	echo " -e                           Ephemeral consumer (i.e. not durable)"
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
	"e")
		EPHEMERAL="yes"
		OPTS="$OPTS --ephemeral"
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
if [ "$NATS_USERNAME" != "" ]; then
	OPTS="$OPTS --user $NATS_USERNAME"
fi
if [ "$NATS_PASSWORD" != "" ]; then
	OPTS="$OPTS --password $NATS_PASSWORD"
fi

STREAM_NAME=$1
if [ "$EPHEMERAL" != "yes" ]; then
	CONSUMER_NAME=$2
else
	CONSUMER_NAME=""
fi

# create event log consumer
# - push-based (which then publish the messages to a target subject and anyone who subscribes to the subject will get them)
# - deliver-group (load-balance amount different instances)
# - instant replay
# - no ack
$DEBUG nats consumer add \
	$OPTS \
	--target="System.EventLog" \
	--deliver-group="EventLog" \
	--filter="" \
	--ack=none \
	--deliver=new \
	--replay=instant \
	--max-deliver=-1 \
	--heartbeat=30s \
	--no-flow-control \
	--no-headers-only \
	$STREAM_NAME \
	$CONSUMER_NAME
