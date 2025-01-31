.PHONY: help
help:
	@echo "Usage:"
	@echo "    docker-up             docker-compose deploy Zitadel for local development"
	@echo "    docker-down           docker-compose remove Zitadel"

# docker docker-up
.PHONY: docker-up
docker-up:
	docker-compose -f docker-compose.yml up

# docker compose down
.PHONY: docker-down
docker-down:
	docker-compose -f docker-compose.yml down
