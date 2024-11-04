#!/bin/bash
cd /usr/share/grafana.kmesh
grafana-server -config /etc/grafana.kmesh/grafana.ini cfg:default.paths.data=/var/lib/grafana.kmesh 1>/var/log/grafana.kmesh.log 2>&1
