.PHONY: vagrant-help
vagrant-help:
	@echo "Usage:"
	@echo "    vagrant-validate      Validate Vagrantfile"
	@echo "    vagrant-up            Vagrant start and provision vagrant machines"
	@echo "    vagrant-suspend       Vagrant suspend vagrant machines"
	@echo "    vagrant-resume        Vagrant resume suspended vagrant machines"
	@echo "    vagrant-halt          Vagrant stop vagrant machines"
	@echo "    vagrant-destroy       Vagrant stop and delete vagrant machines"
	@echo "    vagrant-status        Show vagrant machines status"

# validate Vagrantfile
.PHONY: vagrant-validate
vagrant-validate:
	vagrant validate

# vagrant up
.PHONY: vagrant-up
vagrant-up:
	@if [ "$$VAGRANT_BRIDGE" != "" ] && [ "$$VM_USERNAME" != "" ]; then \
		vagrant up ; \
	else \
		echo "Error: .env variables is not set yet! Please source .env properly." ; \
		exit 1 ; \
	fi

# vagrant suspend
.PHONY: vagrant-suspend
vagrant-suspend:
	vagrant suspend

# vagrant resume
.PHONY: vagrant-resume
vagrant-resume:
	vagrant resume

# vagrant halt
.PHONY: vagrant-halt
vagrant-halt:
	vagrant halt

# vagrant destroy
.PHONY: vagrant-destroy
vagrant-destroy:
	vagrant destroy

# vagrant status
.PHONY: vagrant-status
vagrant-status:
	vagrant status
