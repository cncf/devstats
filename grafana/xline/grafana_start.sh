#!/bin/bash
cd /usr/share/grafana.xline
grafana-server -config /etc/grafana.xline/grafana.ini cfg:default.paths.data=/var/lib/grafana.xline 1>/var/log/grafana.xline.log 2>&1
