#!/bin/bash
#
# Script file to create mongodb replica set Keyfile.
#

KEYFILE_FILENAME="mongodb.keyfile"
NUM_CHAR=756
NUM_ARGS=0
DEBUG=""

# Function
SCRIPT_NAME=${0##*/}
Usage () {
	echo
	echo "Description:"
	echo "Script file to create mongodb replica set Keyfile."
	echo
	echo "Usage: $SCRIPT_NAME"
	echo "Options:"
	echo " -f  [filename]               Keyfile output filename"
	echo " -n  [chars]                  Number of output characters"
	echo " -h                           This help message"
	echo
}

# Parse input argument(s)
while [ "${1:0:1}" == "-" ]; do
	OPT=${1:1:1}
	case "$OPT" in
	"f")
		KEYFILE_FILENAME=$2
		shift
		;;
	"n")
		NUM_CHAR=$2
		shift
		;;
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

# docker exec to the container
$DEBUG openssl rand -base64 $NUM_CHAR > $KEYFILE_FILENAME
$DEBUG chmod 400 $KEYFILE_FILENAME
