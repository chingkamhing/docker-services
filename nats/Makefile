.PHONY: help
help:
	@echo "Usage:"
	@echo "    pub                	 Test publish"
	@echo "    sub                	 Test subscribe"
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
MODE ?= leafcluster
# output binary file name
output_name = broker

# Test publish
.PHONY: pub
pub:	build
	./$(output_name) --nats.url nats.kamching.freemyip.com:4222 --nats.ca_filename cert/kamching.freemyip.com/ca.crt --nats.cert_filename cert/kamching.freemyip.com/client.crt --nats.key_filename cert/kamching.freemyip.com/client.key --nats.insecure=true --nats.username $$MY_LEAF_USERNAME --nats.password $$MY_LEAF_PASSWORD nats pub my-test.nats Nats-1 & \
		./$(output_name) --mqtt.host mqtt.kamching.freemyip.com --mqtt.port 8883 --mqtt.ca_filename cert/kamching.freemyip.com/ca.crt --mqtt.cert_filename cert/kamching.freemyip.com/client.crt --mqtt.key_filename cert/kamching.freemyip.com/client.key --mqtt.insecure=true --mqtt.username $$MY_MQTT_USERNAME --mqtt.password $$MY_MQTT_PASSWORD mqtt pub my-test/mqtt Mqtt-1

# Test subscribe
.PHONY: sub
sub:	build
	./$(output_name) --nats.url nats.kamching.freemyip.com:4222 --nats.ca_filename cert/kamching.freemyip.com/ca.crt --nats.cert_filename cert/kamching.freemyip.com/client.crt --nats.key_filename cert/kamching.freemyip.com/client.key --nats.insecure=true --nats.username $$MY_LEAF_USERNAME --nats.password $$MY_LEAF_PASSWORD nats sub my-test.* & \
		./$(output_name) --mqtt.host mqtt.kamching.freemyip.com --mqtt.port 8883 --mqtt.ca_filename cert/kamching.freemyip.com/ca.crt --mqtt.cert_filename cert/kamching.freemyip.com/client.crt --mqtt.key_filename cert/kamching.freemyip.com/client.key --mqtt.insecure=true --mqtt.username $$MY_MQTT_USERNAME --mqtt.password $$MY_MQTT_PASSWORD mqtt sub my-test/+

# Test tls connection
# for debug purpose:
# - debug why Traefik fail to route nats traffic to nats-external while mqtt works
# - change traefik log level to DEBUG and nats-external log flag to "-DV"
# - the following command "openssl s_client ..." initiate a tls handshake to nats.kamching.freemyip.com:4222 and Traefik successfully route the tls to nats-external (proven by debug log messages)
# - however the above pub or sub commands fail to reach traefik with "i/o timeout", also traefik and nats-external show empty log message
# - although the following command can initiate a tls to nats.kamching.freemyip.com:4222, but have handshake error while mqtt has no error
.PHONY: connect
connect:
	openssl s_client -CAfile cert/kamching.freemyip.com/ca.crt -cert cert/kamching.freemyip.com/client.crt -key cert/kamching.freemyip.com/client.key -connect nats.kamching.freemyip.com:4222
	openssl s_client -CAfile cert/kamching.freemyip.com/ca.crt -cert cert/kamching.freemyip.com/client.crt -key cert/kamching.freemyip.com/client.key -connect mqtt.kamching.freemyip.com:8883

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
