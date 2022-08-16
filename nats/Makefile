.PHONY: help
help:
	@echo "Usage:"
	@echo "    run                	 Run the program"
	@echo "    build                 Build the program"
	@echo "    config                Validate and view the compose file"
	@echo "    docker-up             docker-compose deploy for local development"
	@echo "    docker-down           docker-compose remove"
	@echo "    status                Print nats status"

# nats deploy mode: single, cluster
MODE ?= single

# Run the program
.PHONY: run
run:
	go run *.go

# Build the program
.PHONY: build
build:
	go build -o broker *.go

# validate and view the compose file
.PHONY: config
config:
	docker-compose -f docker-compose-$(MODE).yml config

# docker docker-up
.PHONY: docker-up
docker-up:
	@if [ "$$MY_NATS_ROUTE_USERNAME" != "" ] && [ "$$MY_NATS_ROUTE_PASSWORD" != "" ] && [ "$$MY_NATS_USERNAME" != "" ] && [ "$$MY_MQTT_USERNAME" != "" ]; then \
		docker-compose -f docker-compose-$(MODE).yml up ; \
	else \
		echo "Error: .env variables is not set yet! Please source .env properly." ; \
		exit 1 ; \
	fi

# docker compose down
.PHONY: docker-down
docker-down:
	docker-compose -f docker-compose-$(MODE).yml down

# Print nats status
.PHONY: status
status:
	@echo Stream info:
	@./script/stream-info.sh
	@echo Consumer info:
	@./script/consumer-info.sh
