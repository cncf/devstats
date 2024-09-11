#!/bin/bash
cd /usr/share/grafana.flatcar
grafana-server -config /etc/grafana.flatcar/grafana.ini cfg:default.paths.data=/var/lib/grafana.flatcar 1>/var/log/grafana.flatcar.log 2>&1
