Prometheus + Grafan Setup in a Box

Prometheus needs a Node Exporter to scrape metrics

Add Push Gateway to collect logs from Pipeline runs or external sources
Requires basic auth config for ssecure access, can also use nginx for reverse proxy

Use AlertManager for push notification to Slack, Teams, Pagerduty, email etc


https://www.liquidweb.com/blog/install-prometheus-node-exporter-on-linux-almalinux/


Use Thanos, Cortex, or Remote Write to store data in Azure
https://medium.com/@55_learning/prometheus-high-availability-with-thanos-caf00cfd3a7b 
