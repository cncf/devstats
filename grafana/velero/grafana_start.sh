#!/bin/bash
cd /usr/share/grafana.velero
grafana-server -config /etc/grafana.velero/grafana.ini cfg:default.paths.data=/var/lib/grafana.velero 1>/var/log/grafana.velero.log 2>&1
