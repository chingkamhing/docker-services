#!/bin/bash
#
# Script file to generate ssh config file which can ssh to hostname instead of ip address.
#

SSH_PORT=22
IDENTITYFILE="$HOME/.ssh/id_rsa"
NUM_ARGS=1
DEBUG=""

# Function
SCRIPT_NAME=${0##*/}
Usage () {
	echo
	echo "Description:"
	echo "Script file to generate ssh config file which can ssh to hostname instead of ip address."
	echo
	echo "Usage: $SCRIPT_NAME [host ini file]"
	echo "Options:"
	echo " -p  [ssh port]               ssh port (default: $SSH_PORT)"
	echo " -k  [key file]               ssh private key file (default: $IDENTITYFILE)"
	echo " -h                           This help message"
	echo
}

IsIP() {
	[[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && return 0 || return 1
}

# Parse input argument(s)
while [ "${1:0:1}" == "-" ]; do
	OPT=${1:1:1}
	case "$OPT" in
	"p")
		SSH_PORT=$2
		shift
		;;
	"k")
		IDENTITYFILE=$2
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

# parse arguments
HOST_FILENAME=$1

declare -A map_name_ip=()
declare -A map_name_user=()
vms_json=$(ansible-inventory --inventory $HOST_FILENAME --list)
vm_names=($(echo $vms_json | jq "._meta.hostvars | keys | .[]" | tr -d '"'))
for vm_name in ${vm_names[@]}; do
    vm_ip=$(echo $vms_json | jq ._meta.hostvars.\"$vm_name\".ansible_host | tr -d '"')
    vm_user=$(echo $vms_json | jq ._meta.hostvars.\"$vm_name\".ansible_user | tr -d '"')
    IsIP $vm_ip
    if [ "$?" -ne "0" ]; then
        echo "Invalid ip address in $HOST_FILENAME!"
        exit 1
    fi
    map_name_ip["$vm_name"]=$vm_ip
    map_name_user["$vm_name"]=$vm_user
done

# print the ssh config to stdout
for vm_name in ${!map_name_ip[@]}; do
    host=${map_name_ip[$vm_name]}
    user=${map_name_user[$vm_name]}
    echo "Host $vm_name"
    echo "  HostName $host"
    echo "  Port $SSH_PORT"
    echo "  User $user"
    echo "  IdentityFile $IDENTITYFILE"
    echo
done
