.PHONY: help
help:
	@echo "Usage:"
	@echo "    validate      check ansible file"
	@echo "Vagrant:"
	@echo "    up            Vagrant start and provision vagrant machines"
	@echo "    suspend       Vagrant suspend vagrant machines"
	@echo "    resume        Vagrant resume suspended vagrant machines"
	@echo "    halt          Vagrant stop vagrant machines"
	@echo "    destroy       Vagrant stop and delete vagrant machines"
	@echo "    status        Show vagrant machines status"
	@echo "Ansible:"
	@echo "    dry           Ansible dry-run deploy docker swarm nodes"
	@echo "    deploy        Ansible deploy docker swarm nodes"

#
# Vagrant and Ansible
#

# validate Vagrantfile
.PHONY: validate
validate:
	vagrant validate
	ansible-playbook --syntax-check deploy-swarm.yml

#
# Vagrant
#

# vagrant up
.PHONY: up
up:
	@if [ "$$VAGRANT_BRIDGE" != "" ]; then \
		vagrant up ; \
	else \
		echo "Error: .env variables is not set yet! Please source .env properly." ; \
	fi

# vagrant suspend
.PHONY: suspend
suspend:
	vagrant suspend

# vagrant resume
.PHONY: resume
resume:
	vagrant resume

# vagrant halt
.PHONY: halt
halt:
	vagrant halt

# vagrant destroy
.PHONY: destroy
destroy:
	vagrant destroy

# vagrant status
.PHONY: status
status:
	vagrant global-status
	vagrant status

#
# Ansible
#

# ansible dry-run deploy docker swarm nodes
.PHONY: dry
dry:
	ansible-playbook --check deploy-swarm.yml

# ansible deploy docker swarm nodes
.PHONY: deploy
deploy:
	ansible-playbook deploy-swarm.yml --ask-pass --ask-become-pass
