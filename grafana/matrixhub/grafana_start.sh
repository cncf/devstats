#!/bin/bash
cd /usr/share/grafana.matrixhub
grafana-server -config /etc/grafana.matrixhub/grafana.ini cfg:default.paths.data=/var/lib/grafana.matrixhub 1>/var/log/grafana.matrixhub.log 2>&1
