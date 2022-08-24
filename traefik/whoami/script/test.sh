#!/bin/bash
#
# Test script to test pubg and prig endpoints.
#

DIR="$(dirname "${0}")"

echo "Testing private TLS endpoint: pubg"
${DIR}/check.sh -u https://pubg.local -k
echo "Testing mTLS endpoint: prig"
${DIR}/check.sh -u https://prig.local -k -m
echo "Testing Traefik dashboard web page"
curl -k --cookie-jar .cookie --cookie .cookie -u user:123456 https://traefik.local:8000/
