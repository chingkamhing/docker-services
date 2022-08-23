.PHONY: help
help:
	@echo "Usage:"
	@echo "    build                Build this project locally"
	@echo "    docker               Build docker image"

# docker ID
DOCKER_ID ?= chingkamhing

# output binary file name
output_name = whoami

# Build this project locally
.PHONY: build
build:
	go build -ldflags '-extldflags "-static"' -o $(output_name) *.go

# Build docker image
.PHONY: docker
docker:
	docker build -f Dockerfile -t $(DOCKER_ID)/$(output_name):latest .
