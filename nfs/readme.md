# Deploy NFS Server and Client in Docker

## Install NFS client docker plugin

* install NFS in host PC
    + for Ubuntu/Debian: sudo apt-get install nfs-common
    + for RHEL/CentOS: sudo yum install nfs-utils
* install docker NFS volume plugin (i.e. netshare) in host PC
    + wget https://github.com/ContainX/docker-volume-netshare/releases/download/v0.36/docker-volume-netshare_0.36_amd64.deb
    + sudo dpkg -i docker-volume-netshare_0.36_amd64.deb
* start the service
    + sudo systemctl enable docker-volume-netshare
    + sudo systemctl start docker-volume-netshare
* reference
    + [Docker NFS, AWS EFS & Samba/CIFS Volume Plugin](https://github.com/ContainX/docker-volume-netshare)
    + [NFS Plugin for Raspberry Pi on Docker Swarm](https://blog.pistack.co.za/nfs-plugin-for-raspberry-pi-on-docker-swarm/)

## Docker compose environment

### Setup a NFS server with docker copose

* invoke "make docker-up"
* reference
    + [Setup a NFS Server With Docker](https://blog.ruanbekker.com/blog/2020/09/20/setup-a-nfs-server-with-docker/)
    + [NFS Docker Volumes: How to Create and Use](https://phoenixnap.com/kb/nfs-docker-volumes#:~:text=Volumes%20are%20existing%20directories%20on,NFS%20remote%20file%2Dsharing%20system)
    + [itsthenetwork/nfs-server-alpine](https://hub.docker.com/r/itsthenetwork/nfs-server-alpine)

### Setup a NFS client with docker copose

* invoke "make app-up"
* reference
    + [NFS Docker Volumes: How to Create and Use](https://phoenixnap.com/kb/nfs-docker-volumes#:~:text=Volumes%20are%20existing%20directories%20on,NFS%20remote%20file%2Dsharing%20system)
    + [Mount NFS Share Directly in docker-compose File](https://blog.stefandroid.com/2021/03/03/mount-nfs-share-in-docker-compose.html)

## Docker swarm environment

### Setup a NFS server with docker copose

* invoke "make stack-up"
* FIXME, not working yet
* reference
    + [Docker Swarm Persistent Storage with NFS](https://sysadmins.co.za/docker-swarm-persistent-storage-with-nfs/)
    + [Setup a NFS Server With Docker](https://blog.ruanbekker.com/blog/2020/09/20/setup-a-nfs-server-with-docker/)

### Setup a NFS client with docker copose

* invoke "make app2-up"
* issue
    + somehow, can only mount to the root of nfs server
    + seems unstable, somehow sometime get "exit error 32", need reboot to fix it
* reference
    + [Docker Swarm Persistent Storage with NFS](https://sysadmins.co.za/docker-swarm-persistent-storage-with-nfs/)

## References

* [Docker Swarm Persistent Storage with NFS](https://sysadmins.co.za/docker-swarm-persistent-storage-with-nfs/)
* [Setup a NFS Server With Docker](https://blog.ruanbekker.com/blog/2020/09/20/setup-a-nfs-server-with-docker/)
