# NATS

* have the nats jetstream working now
    + [JetStream Walkthrough](https://docs.nats.io/nats-concepts/jetstream/js_walkthrough)

## Add authentication

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

## References

* [Welcome to the Official NATS Documentation](https://docs.nats.io/)
* [NATS Server Clients](https://docs.nats.io/running-a-nats-service/clients)
* [The NATS Command Line Interface](https://github.com/nats-io/natscli)
* [Golang client for NATS](https://github.com/nats-io/nats.go)
