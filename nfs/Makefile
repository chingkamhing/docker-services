.PHONY: help
help:
	@echo "Usage:"
	@echo "    config                Validate and view the compose file"
	@echo "    docker-up             docker-compose deploy nfs"
	@echo "    docker-down           docker-compose remove nfs"
	@echo "    stack-up              docker stack deploy nfs"
	@echo "    stack-down            docker stack remove nfs"
	@echo "    app-up                docker-compose deploy app"
	@echo "    app-down              docker-compose remove app"
	@echo "    app2-up               docker stack deploy app2"
	@echo "    app2-down             docker stack remove app2"

project = nfs
app2 = app2

# validate and view the compose file
.PHONY: config
config:
	docker-compose -f docker-compose.yml config

# nfs docker compose
.PHONY: docker-up
docker-up:
	docker-compose -f docker-compose.yml up
.PHONY: docker-down
docker-down:
	docker-compose -f docker-compose.yml down

# nfs docker stack
.PHONY: stack-up
stack-up:
	docker stack deploy -c docker-stack.yml $(project)
.PHONY: stack-down
stack-down:
	docker stack rm $(project)

# app docker compose
.PHONY: app-up
app-up:
	docker-compose -f docker-compose-app.yml up
.PHONY: app-down
app-down:
	docker-compose -f docker-compose-app.yml down

# app docker stack
.PHONY: app2-up
app2-up:
	docker stack deploy -c docker-stack-app2.yml $(app2)
.PHONY: app2-down
app2-down:
	docker stack rm $(app2)
