.PHONY: help
help:
	@echo "Usage:"
	@echo "    docker               Build docker image"
	@echo "    docker-up            docker-compose up"
	@echo "    docker-down          docker-compose down"

# docker ID
DOCKER_ID ?= chingkamhing

# output binary file name
output_name = whoami

# Build docker image
.PHONY: docker
docker:
	make -C ${output_name} docker

# docker-compose up
.PHONY: docker-up
docker-up:
	docker-compose -f docker-compose.yml up

# docker-compose down
.PHONY: docker-down
docker-down:
	docker-compose -f docker-compose.yml down
