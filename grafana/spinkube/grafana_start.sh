#!/bin/bash
cd /usr/share/grafana.spinkube
grafana-server -config /etc/grafana.spinkube/grafana.ini cfg:default.paths.data=/var/lib/grafana.spinkube 1>/var/log/grafana.spinkube.log 2>&1
