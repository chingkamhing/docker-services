#!/bin/bash
#
# Script to get or renew tls certificate files from Let's Encrypt with lego.
#
# Note:
# - running without root privileges
#   invoke "sudo setcap 'cap_net_bind_service=+ep' /home/kamching/workspace/go/bin/lego"
#
# References:
# - https://go-acme.github.io/lego/
#

LEGO="/home/kamching/workspace/go/bin/lego"
DOMAIN=""
PROTOCOL="--http"
CERT_PATH=".lego/certificates"
OPTS=""
OPTS_CMD=""
NUM_ARGS=1
DEBUG=""

# Function
SCRIPT_NAME=${0##*/}
Usage () {
	echo
	echo "Description:"
	echo "Script to get or renew tls certificate files from Let's Encrypt with lego."
    echo "e.g."
    echo "  $SCRIPT_NAME -e chingkamhing@gmail.com kamching.freemyip.com"
	echo
	echo "Usage: $SCRIPT_NAME [domain]"
	echo "Options:"
	echo " -d  [days]                   Number of remaining days before renew the certificate"
	echo " -e  [email]                  Email used for registration and recovery contact"
	echo " -k  [hook]                   Cert renew hook script which will be invoked upon successfully renewing certificate"
	echo " -h                           This help message"
	echo
}

# Parse input argument(s)
while [ "${1:0:1}" == "-" ]; do
	OPT=${1:1:1}
	case "$OPT" in
	"e")
		OPTS="$OPTS --email $2"
		shift
		;;
	"d")
		OPTS_CMD="$OPTS_CMD --days $2"
		shift
		;;
	"k")
		OPTS_CMD="$OPTS_CMD --renew-hook $2"
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

DOMAIN=$1

if [ -f "$CERT_PATH/${DOMAIN}.crt" ] && [ -f "$CERT_PATH/${DOMAIN}.key" ]; then
    CMD="renew $OPTS_CMD"
else
    CMD="run $OPTS_CMD"
fi

$DEBUG $LEGO --domains $DOMAIN $PROTOCOL $OPTS $CMD
