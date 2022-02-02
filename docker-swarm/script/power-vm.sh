#!/bin/bash
#
# Script file to power on or off all virtual box VMs.
#

NUM_ARGS=1
DEBUG=""

# Function
SCRIPT_NAME=${0##*/}
Usage () {
	echo
	echo "Description:"
	echo "Script file to power on or off all virtual box VMs."
	echo
	echo "Usage: $SCRIPT_NAME [on/off]"
	echo "Options:"
	echo " -h                           This help message"
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

# parse arguments
POWER=$1
case "$POWER" in
"on")
	cmd="VBoxManage startvm \$vm_name --type headless"
	;;
"off")
	cmd="VBoxManage controlvm \$vm_name acpipowerbutton"
	;;
*)
	Usage
	exit 1
	;;
esac

# virtual box power on or off VMs
IFS=$'\n' vm_list=($(VBoxManage list vms)) ; \
for vm_line in "${vm_list[@]}"; do \
	vm_name=$(echo $vm_line | awk '{ print $1 }' | tr -d '"') ; \
	eval $cmd ; \
done
