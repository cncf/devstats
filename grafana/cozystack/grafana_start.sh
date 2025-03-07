#!/bin/bash
cd /usr/share/grafana.cozystack
grafana-server -config /etc/grafana.cozystack/grafana.ini cfg:default.paths.data=/var/lib/grafana.cozystack 1>/var/log/grafana.cozystack.log 2>&1
