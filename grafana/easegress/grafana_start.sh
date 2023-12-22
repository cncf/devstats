#!/bin/bash
cd /usr/share/grafana.easegress
grafana-server -config /etc/grafana.easegress/grafana.ini cfg:default.paths.data=/var/lib/grafana.easegress 1>/var/log/grafana.easegress.log 2>&1
