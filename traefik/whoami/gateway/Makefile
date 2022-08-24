output := gateway

.PHONY: help
help:
	@echo "Usage:"
	@echo "Makefile commands"
	@echo "    build                Build this project locally"
	@echo "    test                 Perform go test"
	@echo "    docker               Build all services docker images"
	@echo "    clean                Clean this project and database docker volume"

#
# Makefile commands
#

.PHONY: build
build:
	go build -o ${output} *.go

.PHONY: test
test:
	@echo No test implemented yet.

.PHONY: docker
docker:
	docker build --tag ${DOCKER_ID}/${output}:latest .

.PHONY: clean
clean:
	rm -f ${output}
