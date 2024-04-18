#!/bin/bash
cd /usr/share/grafana.kubeslice
grafana-server -config /etc/grafana.kubeslice/grafana.ini cfg:default.paths.data=/var/lib/grafana.kubeslice 1>/var/log/grafana.kubeslice.log 2>&1
