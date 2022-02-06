# Loki

## docker-compose
* start loki
    + invoke "make docker-up"
* get the log
    + visit url "http://localhost:3000/"
    + add data source "Loki" with URL "http://localhost:3100"
    + goto "Explore" tab
    + in "Log browser >", enter '{host=~".+"}' and "Shift + Enter"

## docker-stack
* start loki
    + invoke "make stack-up"
* get the log
    + visit url "http://_your_local_ip_address_:3000/" (e.g. http://192.168.8.22:3000/)
    + add data source "Loki" with URL "http://_your_local_ip_address:3100" (e.g. http://192.168.8.22:3100/)
    + goto "Explore" tab
    + in "Log browser >", enter '{host=~".+"}' and "Shift + Enter"

## Install logcli
* git clone "https://github.com/grafana/loki.git"
* go to directory loki/cmd/logcli/ and invoke "go build *.go"
* invoke "mv main ~/.local/bin/logcli"
* export Loki server url (e.g. "export LOKI_ADDR=http://192.168.8.87:3100")
* list of hosts
    + invoke "logcli labels host"
* list of containers
    + invoke "logcli labels host"

## Reference
* [Grafana Loki Documentation](https://grafana.com/docs/loki/latest/)
* [Grafana documentation](https://grafana.com/docs/grafana/latest/)
