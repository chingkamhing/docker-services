#!/bin/bash
#
# Expect result:
# - every curl should hit the same whoami server when the same cookie is sent
# - if the ".cookie" file deleted, another curl should hit another whoami server
# - and every subsequent curl should hit the same whoami server again as soon as the cookie is sent
#

URL=http://127.0.0.1
PORT=8000
ENDPOINT=""
NUM_ARGS=0
OPTS=""
DEBUG=""

# Function
SCRIPT_NAME=${0##*/}
Usage () {
    echo
    echo "Description:"
    echo "Test if sticky session is working. Expect to hit the same whoami service with the response have the same host name."
    echo
    echo "Usage: $SCRIPT_NAME"
    echo "Options:"
    echo " -k                           Allow insecure server connections when using SSL"
    echo " -m                           Client connection need to be mTLS"
    echo " -v                           Enable curl verbose output"
	echo " -u  [url]                    URL of the gateway"
	echo " -p  [port]                   Port number of the gateway"
	echo " -e  [endpoint]               API endpoint path"
    echo " -h                           This help message"
    echo
}

# Parse input argument(s)
while [ "${1:0:1}" == "-" ]; do
    OPT=${1:1:1}
    case "$OPT" in
    "k")
        OPTS="$OPTS -k"
        ;;
    "m")
        OPTS="$OPTS --cacert certs/prig/ca.crt --cert certs/prig/client-prig.local.crt --key certs/prig/client-prig.local.key"
        ;;
    "v")
        OPTS="$OPTS -v"
        ;;
    "u")
        URL=$2
        shift
        ;;
    "p")
        PORT=$2
        shift
        ;;
    "e")
        ENDPOINT=$2
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

# trim URL trailing "/"
if [ "$PORT" = "" ]; then
	URL="$(echo -e "${URL}" | sed -e 's/\/*$//')"
else
	URL="$(echo -e "${URL}" | sed -e 's/\/*$//')"
	URL="$(echo -e "${URL}:${PORT}" | sed -e 's/\/*$//')"
fi

# strip trailing "/"
URL=${URL%/}
$DEBUG curl --cookie-jar .cookie --cookie .cookie $OPTS ${URL}/${ENDPOINT}
