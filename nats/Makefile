.PHONY: help
help:
	@echo "Usage:"
	@echo "    run                	 Run the program"
	@echo "    build                 Build the program"
	@echo "    test                  Perform go test"
	@echo "    benchmark             Perform go benchmark test on leafcluster deployment"
	@echo "    nkey                  Generate NATS nkey user and seed"
	@echo "    password              Generate some random passwords"
	@echo "    config                Validate and view the compose file"
	@echo "    docker-up             docker-compose deploy for local development; deploy MODE of: single (default), cluster"
	@echo "    docker-down           docker-compose remove"
	@echo "    status                Print nats status"

# nats deploy mode: single, cluster, leafcluster
MODE ?= single
# output binary file name
output_name = broker

# Run the program
.PHONY: run
run:
	go run *.go

# Build the program
.PHONY: build
build:
	CGO_ENABLED=0 go build -ldflags="-extldflags=-static" -o $(output_name) .

# Perform go test
.PHONY: test
test:
	go test -v ./...

# Perform go benchmark test
.PHONY: benchmark
benchmark:
	go test -bench=_MqttQos0Publish ./cmd
	sleep 5s
	go test -bench=_MqttQos1Publish ./cmd
	sleep 5s
	go test -bench=_NatsPublish ./cmd
	sleep 5s
	go test -bench=_JetstreamPublish ./cmd

# Generate NATS nkey user and seed
.PHONY: nkey
nkey:
	nk --gen user --pubout

# Generate some random passwords
.PHONY: password
password:
	./script/generate-password.sh -c 10

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
