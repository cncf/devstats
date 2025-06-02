#!/bin/bash
cd /usr/share/grafana.kagent
grafana-server -config /etc/grafana.kagent/grafana.ini cfg:default.paths.data=/var/lib/grafana.kagent 1>/var/log/grafana.kagent.log 2>&1
