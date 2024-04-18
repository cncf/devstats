#!/bin/bash
cd /usr/share/grafana.connect
grafana-server -config /etc/grafana.connect/grafana.ini cfg:default.paths.data=/var/lib/grafana.connect 1>/var/log/grafana.connect.log 2>&1
