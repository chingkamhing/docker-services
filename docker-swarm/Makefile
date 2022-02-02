.PHONY: help
help:
	@echo "Usage:"
	@echo "VBox:"
	@echo "    create-vm     Create VirtualBox VMs base on hosts.ini"
	@echo "    status        VirtualBox VMs status"
	@echo "    on            VirtualBox power on"
	@echo "    off           VirtualBox power off"
	@echo "    ssh-config    ssh config"
	@echo "Ansible:"
	@echo "    validate      check ansible file"
	@echo "    dry           Ansible dry-run deploy docker swarm nodes"
	@echo "    deploy        Ansible deploy docker swarm nodes"

#
# VirtualBox
#

# Create VirtualBox VMs base on hosts.ini
.PHONY: create-vm
create-vm:
	@if [ "$$VM_USERNAME" != "" ] && [ "$$VM_PASSWORD" != "" ]; then \
		./script/create-vm.sh -f hosts.ini ; \
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
	./script/power-vm.sh on

# VirtualBox power off
.PHONY: off
off:
	./script/power-vm.sh off

# ssh config
.PHONY: ssh-config
ssh-config:
	./script/ssh-config.sh hosts.ini

#
# Ansible
#

# validate Vagrantfile
.PHONY: validate
validate:
	ansible-playbook --syntax-check deploy-swarm.yml

# ansible dry-run deploy docker swarm nodes
.PHONY: dry
dry:
	ansible-playbook --check deploy-swarm.yml

# ansible deploy docker swarm nodes
.PHONY: deploy
deploy:
	@if [ "$$VM_USERNAME" != "" ] && [ "$$VM_PASSWORD" != "" ]; then \
		ansible-playbook deploy-swarm.yml --ask-pass --ask-become-pass ; \
	else \
		echo "Error: .env variables is not set yet! Please source .env properly." ; \
		exit 1 ; \
	fi

# test ansible task
.PHONY: test
test:
	@if [ "$$VM_USERNAME" != "" ] && [ "$$VM_PASSWORD" != "" ]; then \
		ansible-playbook deploy-swarm.yml --start-at-task="init-manager get my ip address" ; \
	else \
		echo "Error: .env variables is not set yet! Please source .env properly." ; \
		exit 1 ; \
	fi
