#!/bin/bash
cd /usr/share/grafana.curvine
grafana-server -config /etc/grafana.curvine/grafana.ini cfg:default.paths.data=/var/lib/grafana.curvine 1>/var/log/grafana.curvine.log 2>&1
