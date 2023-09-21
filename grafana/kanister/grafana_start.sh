#!/bin/bash
cd /usr/share/grafana.kanister
grafana-server -config /etc/grafana.kanister/grafana.ini cfg:default.paths.data=/var/lib/grafana.kanister 1>/var/log/grafana.kanister.log 2>&1
