#!/bin/bash
#
# Prerequitist:
# - update /etc/hosts file so that the hostname matches the TLS SAN name
# - i.e. add "127.0.0.1 my-domain.com nats.my-domain.com mqtt.my-domain.com ws.my-domain.com" in file /etc/hosts
#

curl -k --cacert whoami/cert/my-domain.com/ca.crt --cert whoami/cert/my-domain.com/client.crt --key whoami/cert/my-domain.com/client.key https://nats.my-domain.com:1443