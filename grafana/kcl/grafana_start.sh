#!/bin/bash
cd /usr/share/grafana.kcl
grafana-server -config /etc/grafana.kcl/grafana.ini cfg:default.paths.data=/var/lib/grafana.kcl 1>/var/log/grafana.kcl.log 2>&1
