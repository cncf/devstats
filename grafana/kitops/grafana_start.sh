#!/bin/bash
cd /usr/share/grafana.kitops
grafana-server -config /etc/grafana.kitops/grafana.ini cfg:default.paths.data=/var/lib/grafana.kitops 1>/var/log/grafana.kitops.log 2>&1
