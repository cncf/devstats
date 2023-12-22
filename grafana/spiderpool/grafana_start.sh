#!/bin/bash
cd /usr/share/grafana.spiderpool
grafana-server -config /etc/grafana.spiderpool/grafana.ini cfg:default.paths.data=/var/lib/grafana.spiderpool 1>/var/log/grafana.spiderpool.log 2>&1
