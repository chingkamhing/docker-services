.PHONY: help
help:
	@echo "Usage:"
	@echo "    config               Validate and view the compose file"
	@echo "    stack-up             docker stack deploy for local development"
	@echo "    stack-down           docker stack remove"

# project name
project = mongors

# validate and view the compose file
.PHONY: config
config:
	docker-compose -f docker-compose.yml config

# docker stack-up
.PHONY: stack-up
stack-up:
	./create-key-file.sh -f -o deploy/mongodb.keyfile
	docker stack deploy --with-registry-auth -c docker-compose.yml $(project)
	docker exec -it $$(docker ps --filter name=mongors_db-mongo1 --format {{.ID}}) /root/init-replica-set.sh

# docker stack down
.PHONY: stack-down
stack-down:
	docker stack rm $(project)
