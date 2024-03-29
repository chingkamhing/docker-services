# NATS

* have the nats jetstream working now
    + [JetStream Walkthrough](https://docs.nats.io/nats-concepts/jetstream/js_walkthrough)

## Nats Study [Updated: 2022-08-25]

* this project was mean to try to setup nats core and jetstream as "hello world" study
* single node deployment
    + docker-compose-single.yml was created to setup nats for single deployment
* cluster node deployment
    + docker-compose-cluster.yml was created to setup nats for cluster deployment
* leaf-cluster deployment
    + docker-compose-leafcluster.yml was created to setup nats for leaf-cluster deployment
    + the leaf node is mean for external communication (e.g. web UI through websocket, IoT through MQTT or NATS) that need to handle
        - TLS termination
        - authentication and authorization
        - note: the authentication can only handle static user, don't know yet how to dynamically grant different users authn and authz access (i.e. don't know how to make use of JWT in operator mode)
    + the cluster is mean for internal (i.e. backend) communication (e.g. peer communication between microservices)

## JetStream

* jetstream
    + retention policy
    + acknowledgement models
    + exactly once delivery
* consumer
    + durable or ephemeral
    + push or pull based
    + replay policy
    + acknowledgement policy
+ subscribe from a consumer
    + acknowledging messages

### Usage in microservice

* create a stream for microservice
    + set retention to limits
    + set ack to explicit
    + e.g. 'create-stream.sh itms "itms.>"'
* create log consumer
    + push-based (which then publish the messages to a target subject and anyone who subscribes to the subject will get them)
    + deliver-group (load-balance amount different instances)
    + instant replay
    + no ack
    + e.g. 'create-queue-consumer.sh itms log'
* load-balance microservice subscribe
    + subscribe to the same "target subject" as the push-based consumer
    + subscribe to the same "deliver-group" as the push-based consumer
    + e.g. 'subscribe.sh -q EventLog System.EventLog'
* all instances microservice subscribe
    + subscribe to the same "target subject" as the push-based consumer
    + e.g. 'subscribe.sh User.Permission.Changed'

### References

* [JetStream](https://docs.nats.io/using-nats/developer/develop_jetstream)
* [JetStream Model Deep Dive](https://docs.nats.io/using-nats/developer/develop_jetstream/model_deep_dive)
* [Consumers](https://docs.nats.io/running-a-nats-service/nats_admin/jetstream_admin/consumers)
* [Example](https://docs.nats.io/nats-concepts/jetstream/consumers/example_configuration)
* [What's New](https://docs.nats.io/release-notes/whats_new#jetstream)
* [Managing JetStream](https://docs.nats.io/running-a-nats-service/nats_admin/jetstream_admin)

## Add authentication

### Server Configuration Authentication/Authorization

* route authentication
    + change MY_NATS_ROUTE_USERNAME and MY_NATS_ROUTE_PASSWORD accordingly in file ".env"
    + --user ${MY_NATS_ROUTE_USERNAME} --pass ${MY_NATS_ROUTE_PASSWORD}
* configure user(s)
    + simply add "authorization: { ... }" block in config file
* example usage:
    + nats sub --user nats_user --password nats_user_scret_pssord test
    + nats pub --user nats_user --password nats_user_scret_pssord test Message1

### Decentralized JWT Authentication/Authorization

* create memory resolver
    + memory resolver is easier to maintain and suitable for simple account usage
    + follow [Memory Resolver Tutorial](https://docs.nats.io/running-a-nats-service/configuration/securing_nats/auth_intro/jwt/mem_resolver)
    + create an operator, an account and a user, and with system account
        - nsc init -n TestOperator
        - nsc add account TestAccount
        - nsc edit account -n TestAccount --js-consumer -1 --js-disk-storage -1 --js-mem-storage -1 --js-streams -1
        - nsc add user -a TestAccount -n TestUser
    + follow [Create the Server Config](https://docs.nats.io/running-a-nats-service/configuration/securing_nats/auth_intro/jwt/mem_resolver#create-the-server-config) to generate a config file
        - nsc generate config --mem-resolver --config-file server.conf
    + copy and paste to server config file
* create credential file
    + generate credential file for a user
    + e.g. 'nsc generate creds -a TestAccount -n TestUser > TestUser.creds'
    + need to add parameter "--creds TestUser.creds" for all the nats commands
        - nats sub --creds TestUser.creds test
        - nats pub --creds TestUser.creds test "Message 1"
        - nats stream add --creds TestUser.creds test_stream
        - nats pub test --count=1000 --sleep 1s --creds TestUser.creds "publication #{{Count}} @ {{TimeStamp}}"
        - nats consumer next test_stream TestConsumer1 --count 1000 --creds TestUser.creds
* _Note: seems it cannot config mqtt user to be no_auth_user; so drop it_

## MQTT

* enable mqtt
    + add mqtt config block in config file and add a line of "port: 1883"
    + map the mqtt port from host to docker
* create mqtt client connection
    + nsc create a user and enable "Bearer Token"
    + e.g. "nsc edit user --name MqttUser --account TestAccount --bearer"
    + connect with an arbitrary username with the nsc user's jwt

## References

* [Welcome to the Official NATS Documentation](https://docs.nats.io/)
* [NATS Server Clients](https://docs.nats.io/running-a-nats-service/clients)
* [The NATS Command Line Interface](https://github.com/nats-io/natscli)
* [Golang client for NATS](https://github.com/nats-io/nats.go)
* [TLS handshake error: EOF](https://github.com/nats-io/nats-server/issues/2804)
* jetstream
    + [JetStream](https://docs.nats.io/using-nats/developer/develop_jetstream)
    + [JetStream Model Deep Dive](https://docs.nats.io/using-nats/developer/develop_jetstream/model_deep_dive)
    + [Consumers](https://docs.nats.io/running-a-nats-service/nats_admin/jetstream_admin/consumers)
    + [Example](https://docs.nats.io/nats-concepts/jetstream/consumers/example_configuration)
    + [What's New](https://docs.nats.io/release-notes/whats_new#jetstream)
    + [Managing JetStream](https://docs.nats.io/running-a-nats-service/nats_admin/jetstream_admin)
* open source projects
    + [pitaya](https://github.com/topfreegames/pitaya)
    + [goserver](https://github.com/0990/goserver)
    + [nats-wsmsg](https://github.com/octu0/nats-wsmsg)
    + [golang nats.io websocket](https://github.com/blinkinglight/go-nats.io-websocket)
    + liwords - A site that allows people to play a crossword board game against each other
        - [liwords](https://github.com/domino14/liwords)
        - [macondo](https://github.com/domino14/macondo)
        - [liwords-socket](https://github.com/domino14/liwords-socket)
* traefik
    + [traefik_tcp_mqtt_mosquitto_docker_compose.md](https://gist.github.com/gimiki/628e2ca10f026975f00f34e4d1f4ff23)
    + [Traefik Proxy 2.x and TLS 101](https://traefik.io/blog/traefik-2-tls-101-23b4fbee81f1/)
    + [Mutual TLS through a Reverse Proxy](https://zhimin-wen.medium.com/mutual-tls-through-a-reverse-proxy-da60430fefd)