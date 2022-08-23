#!/bin/bash
#
# Prerequitist:
# - update /etc/hosts file so that the hostname matches the TLS SAN name
# - i.e. add "127.0.0.1 kamching.freemyip.com whoami.kamching.freemyip.com nats.kamching.freemyip.com mqtt.kamching.freemyip.com ws.kamching.freemyip.com" in file /etc/hosts
#

curl -k --cacert whoami/cert/kamching.freemyip.com/ca.crt --cert whoami/cert/kamching.freemyip.com/client.crt --key whoami/cert/kamching.freemyip.com/client.key https://whoami.kamching.freemyip.com:4222
