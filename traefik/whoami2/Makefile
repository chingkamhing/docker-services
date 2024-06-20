output := whoami

.PHONY: help
help:
	@echo "Usage:"
	@echo "Docker commands"
	@echo "    docker-up            docker-compose up"
	@echo "    docker-down          docker-compose down"

#
# Docker commands
#

# docker-compose up
.PHONY: docker-up
docker-up:
	docker-compose -f docker-compose.yml up

# docker-compose down
.PHONY: docker-down
docker-down:
	docker-compose -f docker-compose.yml down
