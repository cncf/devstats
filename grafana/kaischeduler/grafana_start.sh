#!/bin/bash
cd /usr/share/grafana.kaischeduler
grafana-server -config /etc/grafana.kaischeduler/grafana.ini cfg:default.paths.data=/var/lib/grafana.kaischeduler 1>/var/log/grafana.kaischeduler.log 2>&1
