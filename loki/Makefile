.PHONY: help
help:
	@echo "Usage:"
	@echo "    config                Validate and view the compose file"
	@echo "    docker-up             docker-compose up"
	@echo "    docker-down           docker-compose down"
	@echo "    stack-up              docker stack up"
	@echo "    stack-down            docker stack down"

# validate and view the compose file
.PHONY: config
config:
	docker-compose -f docker-stack.yml config

# docker docker up
.PHONY: docker-up
docker-up:
	docker-compose -f docker-compose.yml up

# docker docker down
.PHONY: docker-down
docker-down:
	docker-compose -f docker-compose.yml down

# docker stack up
.PHONY: stack-up
stack-up:
	docker stack deploy -c docker-stack.yml loki

# docker stack down
.PHONY: stack-down
stack-down:
	docker stack remove loki
