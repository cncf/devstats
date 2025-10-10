#!/bin/bash
cd /usr/share/grafana.holmesgpt
grafana-server -config /etc/grafana.holmesgpt/grafana.ini cfg:default.paths.data=/var/lib/grafana.holmesgpt 1>/var/log/grafana.holmesgpt.log 2>&1
