# Proxy Docker Stack

* create a proxy to be shared for all the services under UTMS, CMS, TMS and iTMS
* management endpoints to route to different servers (e.g. new and old endpoints of cms, utms, tms, etc.)
* TLS termination
* centralize cert management
* try to use Let's Encrypt instead of SSL cert manual management
* need to support high availability

## Candidate proxy
* [Traefik Proxy](https://doc.traefik.io/traefik/)
    + pros
        - natively support docker swarm
        - good documentation
        - easier to config (e.g. can config router directly in docker-compose.yml through docker labels)
    + cons
        - high availability feature is limited for community edition
* [HAProxy](http://www.haproxy.org/)
    + pros
        - support docker swarm indirectly through docker's DNS
    + cons
        - compare to traefik, config file is harder to read
+ preliminarily chose to use [Traefik Proxy](https://doc.traefik.io/traefik/)

## Consideration to choose
* good documentation
* easy to config
* support high availability (HA)
* easy to manage in bring-your-own-cert manner
    + upgrade cert without server down time
* need to support Let's Encrypt in the future

## Rule of thumb
* traefik config location
    + static config should be defined in docker compose or stack instead of file (e.g. traefik.yml)
        - mainly because the setting is different between docker compose and docker stack which is one more troublesome to maintain the differences between the two
        - while the different settings between docker compose and docker stack is already defined in docker-compose.yml and docker-stack.yml, better make use of it
    + dynamic config which can be shared between docker compose and docker stack should be defined in a file (i.e. dynamic.yml)
        - e.g. TLS setting, middleware, etc.
    + per service config should be defined in docker compose or stack under the service's "lables"
        - e.g. traefik.enable, routers

## How to setup local development environment
* edit /etc/hosts or C:\Windows\System32\drivers\etc\hosts to map the target host to 127.0.0.1
    + e.g. "127.0.0.1 itms-uat.hk-tess.com"
* either "make docker-up" or "make stack-up" to run the proxy docker
* visit the target url to test of the traefik config is working
    + e.g. https://itms-uat.hk-tess.com/dashboard/
* change "--log.level=INFO" to DEBUG for more log message
    + may take some time to follow all the debug or error messages to troubleshoot

## References
* [How to maintain Session Persistence (Sticky Session) in Docker Swarm](http://www.littlebigextra.com/how-to-maintain-session-persistence-sticky-session-in-docker-swarm-with-multiple-containers/)
* [Entry Points Definition](https://doc.traefik.io/traefik/v1.7/configuration/entrypoints/)
* [mkcert](https://github.com/FiloSottile/mkcert)
* traefik v1:
    + [Traefik Proxy with HTTPS](https://dockerswarm.rocks/traefik-v1/traefik/)
    + [Traefik v1.x](https://jellyfin.org/docs/general/networking/traefik.html)
    + [Managing Multiple Microservices with Traefik in Docker Swarm](https://boxboat.com/2017/10/10/managing-multiple-microservices-with-traefik-in-docker-swarm/)
    + [How to maintain Session Persistence (Sticky Session) in Docker Swarm](http://www.littlebigextra.com/how-to-maintain-session-persistence-sticky-session-in-docker-swarm-with-multiple-containers/)
    + [Basics](https://doc.traefik.io/traefik/v1.7/basics/)
* traefik v2:
    + [How To Use Traefik v2 as a Reverse Proxy for Docker Containers on Ubuntu 20.04](https://www.digitalocean.com/community/tutorials/how-to-use-traefik-v2-as-a-reverse-proxy-for-docker-containers-on-ubuntu-20-04)
    + [Integrate Traefik 2.1 Reverse Proxy with Docker Swarm Services](https://betterprogramming.pub/traefik-2-1-as-a-reverse-proxy-c9e274da0a32)
    + [Traefik Docker Example and Introduction](https://www.middlewareinventory.com/blog/traefik-docker/)
    + [Traefik v2 with Docker Swarm](https://dev.to/ohffs/traefik-v2-with-docker-swarm-2cgh)
    + [Traefik v2 examples](https://github.com/DoTheEvo/Traefik-v2-examples)
    + [traefik examples](https://github.com/frigi83/traefik-examples)
    + [Traefik Proxy with HTTPS](https://dockerswarm.rocks/traefik/)
    + [Traefik 2.0 & Docker 101](https://traefik.io/blog/traefik-2-0-docker-101-fc2893944b9d/)
    + [Traefik 2 & TLS 101](https://traefik.io/blog/traefik-2-tls-101-23b4fbee81f1/)
    + [Container orchestration with Docker Swarm and Traefik](https://www.cometari.com/case-study/container-orchestration-with-docker-swarm-and-traefik)
    + [Yet Another mTLS Tutorial](https://dev.to/badgerbadgerbadgerbadger/yet-another-mtls-tutorial-10pp)
    + [Docker container management with Traefik v2 and Portainer](https://rafrasenberg.com/posts/docker-container-management-with-traefik-v2-and-portainer/)
    + [Traefik 2 High Available Mode](https://levelup.gitconnected.com/traefik-2-high-available-mode-d09c9ec36295)
