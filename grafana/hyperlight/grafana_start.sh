#!/bin/bash
cd /usr/share/grafana.hyperlight
grafana-server -config /etc/grafana.hyperlight/grafana.ini cfg:default.paths.data=/var/lib/grafana.hyperlight 1>/var/log/grafana.hyperlight.log 2>&1
