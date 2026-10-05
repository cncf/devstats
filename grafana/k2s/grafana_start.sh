#!/bin/bash
cd /usr/share/grafana.k2s
grafana-server -config /etc/grafana.k2s/grafana.ini cfg:default.paths.data=/var/lib/grafana.k2s 1>/var/log/grafana.k2s.log 2>&1
