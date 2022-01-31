.PHONY: help
help:
	@echo "Usage:"
	@echo "VBox:"
	@echo "    list          VirtualBox list VMs"
	@echo "    on            VirtualBox power on"
	@echo "    off           VirtualBox power off"
	@echo "Ansible:"
	@echo "    validate      check ansible file"
	@echo "    dry           Ansible dry-run deploy docker swarm nodes"
	@echo "    deploy        Ansible deploy docker swarm nodes"

#
# VirtualBox
#

# VirtualBox list VMs
.PHONY: list
list:
	VBoxManage list vms

# VirtualBox power on
.PHONY: on
on:
	./power-vm.sh on

# VirtualBox power off
.PHONY: off
off:
	./power-vm.sh off

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
	ansible-playbook deploy-swarm.yml --ask-pass --ask-become-pass

# test ansible task
.PHONY: test
test:
	ansible-playbook deploy-swarm.yml --ask-pass --ask-become-pass --start-at-task="get user info from environment variable"
