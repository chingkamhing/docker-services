.PHONY: help
help:
	@echo "Usage:"
	@echo "VBox:"
	@echo "    create-vm     Create VirtualBox VMs base on inventory.ini"
	@echo "    status        VirtualBox VMs status"
	@echo "    on            VirtualBox power on"
	@echo "    off           VirtualBox power off"
	@echo "    ssh-config    Print ssh config setting. May append this output to .ssh/config for passwordless login"
	@echo "Ansible:"
	@echo "    validate      Check ansible file validity"
	@echo "    dry           Ansible dry-run provision docker swarm nodes"
	@echo "    provision     Ansible provision docker swarm nodes"

#
# VirtualBox
#

# Create VirtualBox VMs base on inventory.ini
.PHONY: create-vm
create-vm:
	@if [ "$$VM_USERNAME" != "" ] && [ "$$VM_PASSWORD" != "" ]; then \
		./script/create-vm.sh -f inventory.ini ; \
	else \
		echo "Error: .env variables is not set yet! Please source .env properly." ; \
		exit 1 ; \
	fi

# VirtualBox VMs status
.PHONY: status
status:
	@echo All VMs:
	VBoxManage list vms
	@echo Running VMs:
	VBoxManage list runningvms

# VirtualBox power on
.PHONY: on
on:
	@./script/power-vm.sh on

# VirtualBox power off
.PHONY: off
off:
	@./script/power-vm.sh off

# ssh config
.PHONY: ssh-config
ssh-config:
	@./script/ssh-config.sh inventory.ini

#
# Ansible
#

# validate Vagrantfile
.PHONY: validate
validate:
	@ansible-playbook --syntax-check provision-swarm.yml

# ansible dry-run provision docker swarm nodes
.PHONY: dry
dry:
	@ansible-playbook --check provision-swarm.yml

# ansible provision docker swarm nodes
.PHONY: provision
provision:
	@if [ "$$VM_USERNAME" != "" ] && [ "$$VM_PASSWORD" != "" ]; then \
		ansible-playbook provision-swarm.yml --ask-pass --ask-become-pass ; \
	else \
		echo "Error: .env variables is not set yet! Please source .env properly." ; \
		exit 1 ; \
	fi

# test ansible task
.PHONY: test
test:
	@if [ "$$VM_USERNAME" != "" ] && [ "$$VM_PASSWORD" != "" ]; then \
		ansible-playbook provision-swarm.yml --start-at-task="label docker node" ; \
	else \
		echo "Error: .env variables is not set yet! Please source .env properly." ; \
		exit 1 ; \
	fi
