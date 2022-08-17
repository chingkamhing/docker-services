#!/bin/bash
#
# Generate self cert for domain(s), IP addresses and/or email address. (Note: must have at least one domain name as self-signed cert cannot certificate IP address)
#
# Knowledge base:
# .pem stands for PEM, Privacy Enhanced Mail; it simply indicates a base64 encoding with header and footer lines. Mail traditionally only handles text, not binary which most cryptographic data is, so some kind of encoding is required to make the contents part of a mail message itself (rather than an encoded attachment). The contents of the PEM are detailed in the header and footer line - .pem itself doesn't specify a data type - just like .xml and .html do not specify the contents of a file, they just specify a specific encoding;
# .key can be any kind of key, but usually it is the private key - OpenSSL can wrap private keys for all algorithms (RSA, DSA, EC) in a generic and standard PKCS#8 structure, but it also supports a separate 'legacy' structure for each algorithm, and both are still widely used even though the documentation has marked PKCS#8 as superior for almost 20 years; both can be stored as DER (binary) or PEM encoded, and both PEM and PKCS#8 DER can protect the key with password-based encryption or be left unencrypted;
# .csr or .req or sometimes .p10 stands for Certificate Signing Request as defined in PKCS#10; it contains information such as the public key and common name required by a Certificate Authority to create and sign a certificate for the requester, the encoding could be PEM or DER (which is a binary encoding of an ASN.1 specified structure);
# .crt or .cer stands simply for certificate, usually an X509v3 certificate, again the encoding could be PEM or DER; a certificate contains the public key, but it contains much more information (most importantly the signature by the Certificate Authority over the data and public key, of course).
# [2021-11-14]:
# - grpc has this error "x509: certificate relies on legacy Common Name field, use SANs or temporarily enable Common Name matching with GODEBUG=x509ignoreCN=0"
# - found that after golang 1.15.0, need to use SAN instead of CN as it will be deprecated
#
# Reference:
# - https://gist.github.com/cecilemuller/9492b848eb8fe46d462abeb26656c4f8
# - https://stackoverflow.com/questions/7580508/getting-chrome-to-accept-self-signed-localhost-certificate
# - https://github.com/FiloSottile/mkcert
# - https://downey.io/notes/dev/curl-using-mutual-tls/
# - https://medium.com/@groksrc/create-an-openssl-self-signed-san-cert-in-a-single-command-627fd771f25
#

# settings
COUNTRY="HK"
STATE="My Home State"
LOCATION="My Home Location"
ORGANIZATION="My Home Organization"
ORGANIZATION_UNIT="DEV"
RSA_KEY_BITS=2048
CA_DAYS=3660
CERT_DAYS=3660
DIRNAME=$(dirname $0)
NUM_ARGS=1
DEBUG=""

# Function
SCRIPT_NAME=${0##*/}
Usage () {
    echo
    echo "Description:"
    echo "Generate self cert for domain(s), IP addresses and/or email address. (Note: must have at least one domain name as self-signed cert cannot certificate IP address)"
    echo "e.g."
    echo "  $SCRIPT_NAME localhost 127.0.0.1"
    echo "  $SCRIPT_NAME my-domain.com localhost 192.168.223.64 127.0.0.1 email@my-domain.com"
    echo
    echo "Usage: $SCRIPT_NAME [domain / ip / email] ..."
    echo "Options:"
    echo " -r  [bits]                   RSA key bits (e.g. 2048, 4096; default $RSA_KEY_BITS)"
    echo " -a  [days]                   CA valid days (default $CA_DAYS)"
    echo " -e  [days]                   Certificate valid days (default $CERT_DAYS)"
    echo " -c                           Generate client certificates as well"
    echo " -o  [path]                   Certificates output path"
    echo " -v                           View certificate signing request (CSR) and certificate (CRT) output"
    echo " -h                           Print this help message"
    echo
}

# find the SAN type of: IP_ADDRESS, EMAIL, DNS
FindSanType () {
    local input=$1
    if [[ $input =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "IP_ADDRESS"
    elif [[ $input =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$ ]]; then
        echo "EMAIL"
    else
        echo "DNS"
    fi
}

# Parse input argument(s)
while [ "${1:0:1}" == "-" ]; do
    OPT=${1:1:1}
    case "$OPT" in
    "r")
        RSA_KEY_BITS=$2
        shift
        ;;
    "a")
        CA_DAYS=$2
        shift
        ;;
    "e")
        CERT_DAYS=$2
        shift
        ;;
    "c")
        GENERATE_CLIENT_CERT="yes"
        ;;
    "o")
        OUTPUT_PATH=$2
        shift
        ;;
    "v")
        VIEW_OUTPUT="yes"
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

# seperate arguments to domain and ip address
IP_ADDRESSES=()
EMAIL=()
DOMAINS=()
SAN_NAMES=""
for arg in "$@"; do
    type=$(FindSanType $arg)
    case "$type" in
    "IP_ADDRESS")
        IP_ADDRESSES+=($arg)
        SAN_NAMES=$([ "$SAN_NAMES" == "" ] && echo "IP:$arg" || echo "$SAN_NAMES,IP:$arg")
        ;;
    "EMAIL")
        EMAIL+=($arg)
        SAN_NAMES=$([ "$SAN_NAMES" == "" ] && echo "email:$arg" || echo "$SAN_NAMES,email:$arg")
        ;;
    *)
        DOMAINS+=($arg)
        SAN_NAMES=$([ "$SAN_NAMES" == "" ] && echo "DNS:$arg" || echo "$SAN_NAMES,DNS:$arg")
        ;;
    esac
done
CONFIG=$(cat <<EOF
[req]
distinguished_name=req
[san]
subjectAltName=$SAN_NAMES
EOF
)

# assume the first argument be the domain name
DOMAIN=${DOMAINS[0]}
if [ "$DOMAIN" == "" ]; then
    echo "Invalid parameter! Must have at least one domain name."
	Usage
	exit 1
fi

# create output directory
OUTPUT_PATH=${OUTPUT_PATH:-$DOMAIN}
if [ ! -d "${OUTPUT_PATH}" ]; then
    echo "Directory $OUTPUT_PATH not found, create it"
    mkdir -p $OUTPUT_PATH
fi

# change following config when need
CAKEY="${OUTPUT_PATH}/ca.key"
CACRT="${OUTPUT_PATH}/ca.crt"
SERVER_PRIKEY="${OUTPUT_PATH}/server.key"
SERVER_CSR="${OUTPUT_PATH}/server.csr"
SERVER_CRT="${OUTPUT_PATH}/server.crt"
CLIENT_PRIKEY="${OUTPUT_PATH}/client.key"
CLIENT_CSR="${OUTPUT_PATH}/client.csr"
CLIENT_CRT="${OUTPUT_PATH}/client.crt"
CN="$DOMAIN"

# subject for root certificate
SUBJECT_CA="/C=${COUNTRY}/ST=${STATE}/L=${LOCATION}/CN=${ORGANIZATION}"
SUBJECT_SERVER="/C=${COUNTRY}/ST=${STATE}/L=${LOCATION}/O=${ORGANIZATION}/OU=${ORGANIZATION_UNIT}/CN=${CN}"
SUBJECT_CLIENT="/C=${COUNTRY}/ST=${STATE}/L=${LOCATION}/O=${ORGANIZATION}/OU=${ORGANIZATION_UNIT}/CN=${CN}-client"

# This creates a new private key with a password for the CA (flag aes256 require AES256 password protect)
$DEBUG openssl genrsa -out $CAKEY $RSA_KEY_BITS
# Now we can create the root CA certificate using the SHA256 hash algorithm
$DEBUG openssl req -new -x509 -sha256 -days $CA_DAYS -key $CAKEY -out $CACRT -subj "$SUBJECT_CA"

# use the ca to create server cert and private key
serial=0x$(openssl rand -hex 16)
$DEBUG openssl genrsa -out $SERVER_PRIKEY $RSA_KEY_BITS
$DEBUG openssl req -new -sha256 -key $SERVER_PRIKEY -subj "$SUBJECT_SERVER" -config <( echo "$CONFIG") -extensions san -out $SERVER_CSR
$DEBUG openssl x509 -req -sha256 -days $CERT_DAYS -in $SERVER_CSR -CA $CACRT -CAkey $CAKEY -extfile <( echo "$CONFIG") -extensions san -set_serial $serial -out $SERVER_CRT

# verify
echo "Verify server cert $DOMAIN"
$DEBUG openssl verify -CAfile $CACRT $SERVER_CRT

if [ "$GENERATE_CLIENT_CERT" == "yes" ]; then
    # use the ca to create client cert and private key
    serial=0x$(openssl rand -hex 16)
    $DEBUG openssl genrsa -out $CLIENT_PRIKEY $RSA_KEY_BITS
    $DEBUG openssl req -new -sha256 -key $CLIENT_PRIKEY -subj "$SUBJECT_CLIENT" -config <( echo "$CONFIG") -extensions san -out $CLIENT_CSR
    $DEBUG openssl x509 -req -sha256 -days $CERT_DAYS -in $CLIENT_CSR -CA $CACRT -CAkey $CAKEY -extfile <( echo "$CONFIG") -extensions san -set_serial $serial -out $CLIENT_CRT
    # verify
    echo "Verify client cert $DOMAIN"
    $DEBUG openssl verify -CAfile $CACRT $CLIENT_CRT
fi

# view the CSR and certificate
if [ "$VIEW_OUTPUT" == "yes" ]; then
    echo $CACRT:
    $DEBUG openssl x509 -noout -text -in $CACRT
    echo $SERVER_CRT:
    $DEBUG openssl x509 -noout -text -in $SERVER_CRT
    if [ "$GENERATE_CLIENT_CERT" == "yes" ]; then
        echo $CLIENT_CRT:
        $DEBUG openssl x509 -noout -text -in $CLIENT_CRT
    fi
fi
