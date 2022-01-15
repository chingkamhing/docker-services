.PHONY: help
help:
	@echo "Usage:"
	@echo "    config               Validate and view the compose file"
	@echo "    stack-up             docker stack deploy for local development"
	@echo "    stack-down           docker stack remove"

# project name
project = mongors

# validate and view the compose file
.PHONY: config
config:
	docker-compose -f docker-stack.yml config

# docker stack-up
.PHONY: stack-up
stack-up:
	@if [ "$$MY_MONOGO_REPLICA_SET_NAME" != "" ] && [ "$$MY_INITDB_ROOT_USERNAME" != "" ]; then \
		./create-key-file.sh -f -o deploy/mongodb.keyfile && \
		docker stack deploy --with-registry-auth -c docker-stack.yml $(project) ; \
	else \
		echo "Error: .env variables is not set yet! Please source .env properly." ; \
		exit 1 ; \
	fi

# docker stack down
.PHONY: stack-down
stack-down:
	docker stack rm $(project)
