.PHONY: help
help:
	@echo "Usage:"
	@echo "    docker-up             docker-compose deploy for local development; deploy MODE of: single (default), cluster"
	@echo "    docker-down           docker-compose remove"

# docker docker-up
.PHONY: docker-up
docker-up:
	@if [ "$$DATABASE_DBNAME" != "" ] && [ "$$DATABASE_USER" != "" ]; then \
		docker-compose -f docker-compose.yml up ; \
	else \
		echo "Error: .env variables is not set yet! Please source .env properly." ; \
		exit 1 ; \
	fi

# docker compose down
.PHONY: docker-down
docker-down:
	docker-compose -f docker-compose.yml down
