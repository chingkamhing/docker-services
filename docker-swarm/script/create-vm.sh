#!/bin/bash
#
# Script file to use VirtualBox to create VM.
#
# Reference:
# - https://www.virtualbox.org/manual/ch08.html#vboxmanage-modifyvm-networking
# - https://andreafortuna.org/2019/10/24/how-to-create-a-virtualbox-vm-from-command-line/
#

VM_DIRECTORY="$HOME/VirtualMachines"
# invoke "VBoxManage list ostypes" to get all supported OS types
VM_OSTYPE="RedHat_64"
VM_CPUS=${VM_CPUS:-1}
VM_MEMORY=${VM_MEMORY:-1024}
VM_VRAM=16
VM_NIC="bridged"
VM_DISK_SIZE=100000
VM_BRIDGE_ADAPTER=$(ip addr | awk '/state UP/ {print $2}' | head -n 1 | tr -d ':')
VM_LOCALE="en_US"
VM_COUNTRY="HK"
VM_TIME_ZONE="Asia/Hong_Kong"
# iso file that downloaded in VM_DIRECTORY
ISO_FILENAME="CentOS-7-x86_64-Minimal-2009.iso"
ISO_URL="http://mirror-hk.koddos.net/centos/7.9.2009/isos/x86_64/"
NUM_ARGS=1
DEBUG=""

# Function
SCRIPT_NAME=${0##*/}
Usage () {
	echo
	echo "Description:"
	echo "Script file to use VirtualBox to create VM."
	echo
	echo "Usage: $SCRIPT_NAME [vm name] ..."
	echo "Options:"
	echo " -f  [host file]              hosts filename (ini file format)"
	echo " -i  [iso file]               iso filename (ini file format)"
	echo " -c  [num cpus]               Number of CPUs (default: $VM_CPUS)"
	echo " -m  [memory size]            Memory size in MB (default: $VM_MEMORY)"
	echo " -b  [bridge adapter]         Network bridge adapter device name (default: $VM_BRIDGE_ADAPTER)"
	echo " -h                           This help message"
	echo
}

Prompt () {
	local prompt=$1
	if [ "$IS_PROMPT_PROCEED" == "yes" ]; then
		echo "Y"
		return
	fi
	local is_proceed
	echo -e "$prompt [Y/n]" > /dev/tty
	read is_proceed
	echo "$is_proceed"
}

CreateVm () {
    local create_vm_name=$1
    local iso_file=$2
    local vm_dir=$3
    local vdi_file=${vm_dir}/${vm_name}/${vm_name}.vdi
    IFS=$'\n' vm_list=($(VBoxManage list vms))
    for vm_line in "${vm_list[@]}"; do
        local vm_name=$(echo $vm_line | awk '{ print $1 }' | tr -d '"')
        if [ "$create_vm_name" == "$vm_name" ]; then
            return 1
        fi
    done

    # create VM
    VBoxManage createvm --name $create_vm_name --ostype $VM_OSTYPE --register --basefolder $vm_dir
    # set cpu, memory and network
    VBoxManage modifyvm $create_vm_name --ioapic on
    VBoxManage modifyvm $create_vm_name --cpus $VM_CPUS --memory $VM_MEMORY --vram $VM_VRAM
    VBoxManage modifyvm $create_vm_name --nic1 $VM_NIC --bridgeadapter1 $VM_BRIDGE_ADAPTER
    # create hard disk and optical disk
    VBoxManage createhd --filename ${vdi_file} --size $VM_DISK_SIZE --format VDI
    VBoxManage storagectl $create_vm_name --name "SATA Controller" --add sata --controller IntelAhci
    VBoxManage storageattach $create_vm_name --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium ${vdi_file}
    VBoxManage storageattach $create_vm_name --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium ${iso_file}
    VBoxManage modifyvm $create_vm_name --boot1 dvd --boot2 disk --boot3 none --boot4 none
	VBoxManage unattended install $create_vm_name --user=$VM_USERNAME --password=$VM_PASSWORD --locale=$VM_LOCALE --country=$VM_COUNTRY --time-zone=$VM_TIME_ZONE --iso=$iso_file --start-vm=headless
    return 0
}

# Parse input argument(s)
while [ "${1:0:1}" == "-" ]; do
	OPT=${1:1:1}
	case "$OPT" in
	"f")
		HOST_FILENAME=$2
		shift
		;;
	"i")
		ISO_FILENAME=$2
		shift
		;;
	"c")
		VM_CPUS=$2
		shift
		;;
	"m")
		VM_MEMORY=$2
		shift
		;;
	"b")
		VM_BRIDGE_ADAPTER=$2
		shift
		;;
	"h")
		Usage
		exit
		;;
	esac
	shift
done

if [ "$#" -lt "$NUM_ARGS" ] && [ "$HOST_FILENAME" == "" ]; then
    echo "Invalid parameter!"
	Usage
	exit 1
fi

# parse inputs
if [ "$HOST_FILENAME" == "" ]; then
    VM_NAMES=($@)
else
    echo "Create VMs from $HOST_FILENAME"
    VM_NAMES=()
    while read -r line; do
        if echo $line | grep "[ \t]*#.*" > /dev/null ; then
            continue
        elif echo $line | grep "^[[].*[]]$" > /dev/null ; then
            continue
        elif [[ $line == "" ]] ; then
            continue
        fi
        line_vm=$(echo $line | awk '{ print $1 }')
        VM_NAMES+=("$line_vm")
    done < $HOST_FILENAME
fi

is_proceed=$(Prompt "Create VMs ${VM_NAMES[*]}?")
if [ "$is_proceed" != "Y" ]; then
    echo "Abort creating VMs."
    exit
fi

# create vm directory if not exist
if [ ! -d "$VM_DIRECTORY" ]; then
    mkdir $VM_DIRECTORY
fi

# Download debian.iso
if [ ! -f "${VM_DIRECTORY}/${ISO_FILENAME}" ]; then
    wget $ISO_URL -O ${VM_DIRECTORY}/${ISO_FILENAME}
fi

for vm_name in ${VM_NAMES[@]}; do
    CreateVm $vm_name ${VM_DIRECTORY}/${ISO_FILENAME} ${VM_DIRECTORY}
    if [ "$?" != "0" ]; then
        echo "VM \"$vm_name\" already exist! Stop creating VM."
    fi
done
