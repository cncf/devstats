#!/bin/bash
cd /usr/share/grafana.headlamp
grafana-server -config /etc/grafana.headlamp/grafana.ini cfg:default.paths.data=/var/lib/grafana.headlamp 1>/var/log/grafana.headlamp.log 2>&1
