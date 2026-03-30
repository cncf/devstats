#!/bin/bash
cd /usr/share/grafana.openeverest
grafana-server -config /etc/grafana.openeverest/grafana.ini cfg:default.paths.data=/var/lib/grafana.openeverest 1>/var/log/grafana.openeverest.log 2>&1
