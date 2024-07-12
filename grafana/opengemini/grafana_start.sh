#!/bin/bash
cd /usr/share/grafana.opengemini
grafana-server -config /etc/grafana.opengemini/grafana.ini cfg:default.paths.data=/var/lib/grafana.opengemini 1>/var/log/grafana.opengemini.log 2>&1
