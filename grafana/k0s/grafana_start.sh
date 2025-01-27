#!/bin/bash
cd /usr/share/grafana.k0s
grafana-server -config /etc/grafana.k0s/grafana.ini cfg:default.paths.data=/var/lib/grafana.k0s 1>/var/log/grafana.k0s.log 2>&1
