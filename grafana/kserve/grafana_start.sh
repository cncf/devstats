#!/bin/bash
cd /usr/share/grafana.kserve
grafana-server -config /etc/grafana.kserve/grafana.ini cfg:default.paths.data=/var/lib/grafana.kserve 1>/var/log/grafana.kserve.log 2>&1
