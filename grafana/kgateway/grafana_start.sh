#!/bin/bash
cd /usr/share/grafana.kgateway
grafana-server -config /etc/grafana.kgateway/grafana.ini cfg:default.paths.data=/var/lib/grafana.kgateway 1>/var/log/grafana.kgateway.log 2>&1
