.PHONY: help
help:
	@echo "Usage:"
	@echo "    validate      Validate Vagrantfile"
	@echo "    up            Vagrant start and provision vagrant machines"
	@echo "    suspend       Vagrant suspend vagrant machines"
	@echo "    resume        Vagrant resume suspended vagrant machines"
	@echo "    halt          Vagrant stop vagrant machines"
	@echo "    destroy       Vagrant stop and delete vagrant machines"
	@echo "    status        Show vagrant machines status"

# validate Vagrantfile
.PHONY: validate
validate:
	vagrant validate

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
