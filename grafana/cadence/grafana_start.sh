#!/bin/bash
cd /usr/share/grafana.cadence
grafana-server -config /etc/grafana.cadence/grafana.ini cfg:default.paths.data=/var/lib/grafana.cadence 1>/var/log/grafana.cadence.log 2>&1
