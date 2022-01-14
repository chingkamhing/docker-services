.PHONY: help
help:
	@echo "Usage:"
	@echo "    docker               Build all services docker images"
	@echo "    docker-push          Push docker image to docker hub"
	@echo "    docker-pull          Pull docker image to docker hub"
	@echo "    docker-up            docker-compose up"
	@echo "    docker-down          docker-compose down"
	@echo "    stack-up             docker stack deploy for local development"
	@echo "    stack-down           docker stack remove"

# project name
project = mongors

# validate and view the compose file
.PHONY: config
config:
	docker-compose -f docker-compose.yml config

# build the microservice dockers
.PHONY: docker
docker:
	docker-compose -f docker-compose.yml build

# push docker image to docker hub
.PHONY: docker-push
docker-push:
	docker-compose -f docker-compose.yml push

# pull docker image to docker hub
.PHONY: docker-pull
docker-pull:
	docker-compose -f docker-compose.yml pull

# docker-compose up
.PHONY: docker-up
docker-up:
	docker-compose -f docker-compose.yml up

# docker-compose down
.PHONY: docker-down
docker-down:
	docker-compose -f docker-compose.yml down

# docker stack-up
.PHONY: stack-up
stack-up:
	./create-key-file.sh -f -o deploy/mongodb.keyfile
	docker stack deploy --with-registry-auth -c docker-compose.yml $(project)

# docker stack down
.PHONY: stack-down
stack-down:
	docker stack rm $(project)
