#!/bin/bash
cd /usr/share/grafana.microcks
grafana-server -config /etc/grafana.microcks/grafana.ini cfg:default.paths.data=/var/lib/grafana.microcks 1>/var/log/grafana.microcks.log 2>&1
