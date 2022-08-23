#!/bin/bash
#
# Prerequitist:
# - update /etc/hosts file so that the hostname matches the TLS SAN name
# - i.e. add "127.0.0.1 my-domain.com" in file /etc/hosts
#

curl http://my-domain.com:1443