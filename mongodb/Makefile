.PHONY: help
help:
	@echo "Usage:"
	@echo "    config                Validate and view the compose file"
	@echo "    docker-up             docker-compose deploy for local development"
	@echo "    docker-down           docker-compose remove"

# validate and view the compose file
.PHONY: config
config:
	docker-compose -f docker-compose.yml config

# docker docker-up
.PHONY: docker-up
docker-up:
	@if [ "$$DATABASE_NAME" != "" ]; then \
		docker-compose -f docker-compose.yml up ; \
	else \
		echo "Error: .env variables is not set yet! Please source .env properly." ; \
		exit 1 ; \
	fi

# docker compose down
.PHONY: docker-down
docker-down:
	docker-compose -f docker-compose.yml down
