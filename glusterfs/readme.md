# Deploy GlusterFS Server and Client in Docker

## Install

* For Ubuntu
    + sudo apt-get install software-properties-common
    + sudo add-apt-repository ppa:gluster/glusterfs-7
    + sudo apt install glusterfs-server
    + sudo systemctl start glusterd
    + sudo systemctl enable glusterd
* For Red Hat/CentOS
    + sudo yum install centos-release-gluster

* reference
    + [Install](https://docs.gluster.org/en/latest/Install-Guide/Install/)

## References

* [Tutorial: Create a Docker Swarm with Persistent Storage Using GlusterFS](https://thenewstack.io/tutorial-create-a-docker-swarm-with-persistent-storage-using-glusterfs/)
* [Docker Swarm Persistent Storage](https://theworkaround.com/2019/05/15/docker-swarm-persistent-storage.html)
* [Tutorial: Deploy a Highly Availability GlusterFS Storage Cluster](https://thenewstack.io/tutorial-deploy-a-highly-availability-glusterfs-storage-cluster/)
* [GlusterFS for Persistent Docker Volumes](https://autoize.com/glusterfs-for-persistent-docker-volumes/)
* [Docker Swarm Persistent Storage Using GlusterFS](https://medium.com/cloudnesil/docker-swarm-with-persistent-storage-using-glusterfs-48d8cdb84e7c)
* [GlusterFS Documentation](https://docs.gluster.org/en/latest/)
