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

## Reference
* [Loki quick tip: How to create a Grafana dashboard for searching logs using Loki and Prometheus](https://grafana.com/blog/2020/04/08/loki-quick-tip-how-to-create-a-grafana-dashboard-for-searching-logs-using-loki-and-prometheus/)
