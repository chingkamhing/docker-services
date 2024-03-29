.PHONY: help
help:
	@echo "Usage:"
	@echo "Docker commands"
	@echo "    docker-up            docker-compose up"
	@echo "    docker-down          docker-compose down"
	@echo "    stack-up             Deploy a docker stack"
	@echo "    stack-down           Remove a docker stack"
	@echo "    stack-stats          Show a docker stack status"

# project name
project = acme

#
# Docker commands
#

# docker-compose up
.PHONY: docker-up
docker-up:
	@if [ "$$FREEMYIP_TOKEN" != "" ]; then \
		docker-compose -f docker-compose-common.yml -f docker-compose.yml up ; \
	else \
		echo "Error: .env variables is not set yet! Please source .env properly." ; \
	fi

# docker-compose down
.PHONY: docker-down
docker-down:
	docker-compose -f docker-compose-common.yml -f docker-compose.yml down

# Deploy a docker stack
.PHONY: stack-up
stack-up:
	@if [ "$$FREEMYIP_TOKEN" != "" ]; then \
		docker stack deploy -c docker-compose-common.yml -c docker-stack.yml ${project} ; \
	else \
		echo "Error: .env variables is not set yet! Please source .env properly." ; \
	fi

# Remove a docker stack
.PHONY: stack-down
stack-down:
	docker stack rm ${project}

# Show a docker stack status
.PHONY: stack-stats
stack-stats:
	docker node ls
	docker service ls
	docker stack services ${project}
	@nodes=$$(docker node ls --format {{.Hostname}}) ; \
	for node in $$nodes; do \
		docker node ps $$node --filter "desired-state=running" ; \
	done
