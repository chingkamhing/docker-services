# MongoDB Replica Set
* automatically deploy mongodb replica set of 3 in docker swarm
* change ".env" and "deploy/init-replica-set.sh" for different settings

## How to deploy
* install docker swarm and start docker node(s) accordingly
* deployment
    + change the settings in docker-stack.yml if appropriate (e.g. mongo version, deploy constraints, etc.)
    + copy .env.example to .env, change the env settings accordingly
    + invoke "make stack-up" to deploy mongodb replica set
    + invoke "docker service logs -f mongors_db-mongo1" to view the log of primary node
    + will take some time to have the replica set fully functional (typically >30s)
    + will create an admin user
    + refer to "deploy/init-replica-set.sh" for detail of the replica set settings
* stop deployment
    + invoke "make stack-down" to stop the stack
    + invoke "make stack-down && sleep 20s && docker volume rm mongors_mongodb1 mongors_mongodb2 mongors_mongodb3" to stop and delete the volumes

## References
* Mongodb Replica Set
    + [Create a replica set in MongoDB with Docker Compose](https://blog.tericcabrel.com/mongodb-replica-set-docker-compose/)
    + [Deploy MongoDB replica set on Docker swarm](https://harrytang.xyz/blog/mongodb-replica-docker-swarm)
    + [Deploy Replica Set With Keyfile Authentication](https://docs.mongodb.com/manual/tutorial/deploy-replica-set-with-keyfile-access-control/)
    + [Setup MongoDb ReplicaSet with Authentication enabled, using docker-compose.](https://prashix.medium.com/setup-mongodb-replicaset-with-authentication-enabled-using-docker-compose-5edd2ad46a90)
    + [Run multiple services in a container](https://docs.docker.com/config/containers/multi-service_container/)
