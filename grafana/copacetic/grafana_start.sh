#!/bin/bash
cd /usr/share/grafana.copacetic
grafana-server -config /etc/grafana.copacetic/grafana.ini cfg:default.paths.data=/var/lib/grafana.copacetic 1>/var/log/grafana.copacetic.log 2>&1
