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
	docker-compose -f docker-compose.yml up
.PHONY: app-up
app-up:
	docker-compose -f docker-compose-app.yml up

# docker compose down
.PHONY: docker-down
docker-down:
	docker-compose -f docker-compose.yml down
.PHONY: app-down
app-down:
	docker-compose -f docker-compose-app.yml down
