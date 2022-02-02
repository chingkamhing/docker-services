#!/bin/bash
#
# Script file to generate ssh config file which can ssh to hostname instead of ip address.
# Note: expect the hosts ini file in format of "[host name] ansible_host=[ip address] ..."
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
    echo "Note: expect the hosts ini file in format of \"[host name] ansible_host=[ip address] ...\""
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
while read -r line; do
    if echo $line | grep "[ \t]*#.*" > /dev/null ; then
        # comment line, skip
        continue
    elif echo $line | grep "^[[].*[]]$" > /dev/null ; then
        # group name, skip
        continue
    elif [[ $line == "" ]] ; then
        # empty line, skip
        continue
    fi
    IFS=" "
    read -a words <<< "$line"
    vm_name="${words[0]}"
    for word in "${words[@]}"; do
        if [[ $word =~ ^ansible_host=* ]]; then
            IFS="=" read -a values <<< "$word"
            host="${values[1]}"
            IsIP $host
            if [ "$?" -ne "0" ]; then
                echo "Invalid ip address in $HOST_FILENAME!"
                exit 1
            fi
    		map_name_ip["$vm_name"]=$host
        fi
    done
    # map_name_ip["$docker_manager_prefix-$manager_num"]=$labels
done < $HOST_FILENAME

# print the ssh config to stdout
for vm_name in ${!map_name_ip[@]}; do
    host=${map_name_ip[$vm_name]}
    echo "Host $vm_name"
    echo "  HostName $host"
    echo "  Port $SSH_PORT"
    echo "  IdentityFile $IDENTITYFILE"
    echo
done
