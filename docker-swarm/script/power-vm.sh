#!/bin/bash
#
# Script file to power on or off specified or all virtual box VMs.
#

NUM_ARGS=1
DEBUG=""

# Function
SCRIPT_NAME=${0##*/}
Usage () {
	echo
	echo "Description:"
	echo "Script file to power on or off specified or all virtual box VMs."
	echo
	echo "Usage: $SCRIPT_NAME [on/off] [optional VMs...]"
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

if [ "$#" -lt "$NUM_ARGS" ]; then
    echo "Invalid parameter!"
	Usage
	exit 1
fi

# parse arguments
POWER=$1
shift
VM_NAMES=($@)
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

# if VM_NAMES is is not specified, use all virtualbox VMs
if [ "${#VM_NAMES}" -eq "0" ]; then
	IFS=$'\n' vm_list=($(VBoxManage list vms))
	for vm_line in "${vm_list[@]}"; do
		vm_name=$(echo $vm_line | awk '{ print $1 }' | tr -d '"')
		VM_NAMES+=($vm_name)
	done
fi

# virtual box power on or off VMs
for vm_name in "${VM_NAMES[@]}"; do
	eval $cmd
done
