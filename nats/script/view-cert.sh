#!/bin/bash
#
# View the SSL request (*.csr), certificate (*.crt, *.cer), PKCS#12 (*.p12, *.pfx) and rsa key (*.key) file.
#

DIRNAME=$(dirname $0)
NUM_ARGS=1
DEBUG=""

# Function
SCRIPT_NAME=${0##*/}
Usage () {
    echo
    echo "Description:"
    echo "View the SSL request (*.csr), certificate (*.crt, *.cer), PKCS#12 (*.p12, *.pfx) and rsa key (*.key) file."
    echo "e.g."
    echo "  $SCRIPT_NAME tess.hk-tess.com/server.crt"
    echo
    echo "Usage: $SCRIPT_NAME [csr/crt/p12/key file]"
    echo "Options:"
    echo " -h                           Print this help message"
    echo
}

# Parse input argument(s)
while [ "${1:0:1}" == "-" ]; do
    OPT=${1:1:1}
    case "$OPT" in
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

# parse parameters
FILE=$1
ext=${FILE##*.}

# view the CSR and certificate
case "$ext" in
"csr")
    # csr file
    $DEBUG openssl req -noout -text -in $FILE
    ;;
"key")
    # key file; assume rsa
    $DEBUG openssl rsa -noout -text -in $FILE
    ;;
"p12" | "pfx")
    # p12/pfx file
    $DEBUG openssl pkcs12 -noout -info -in $FILE
    ;;
*)
    # assume cert file
    $DEBUG openssl x509 -noout -text -in $FILE
    ;;
esac
