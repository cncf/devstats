#!/bin/bash
cd /usr/share/grafana.radius
grafana-server -config /etc/grafana.radius/grafana.ini cfg:default.paths.data=/var/lib/grafana.radius 1>/var/log/grafana.radius.log 2>&1
