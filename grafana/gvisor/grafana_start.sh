#!/bin/bash
cd /usr/share/grafana.gvisor
grafana-server -config /etc/grafana.gvisor/grafana.ini cfg:default.paths.data=/var/lib/grafana.gvisor 1>/var/log/grafana.gvisor.log 2>&1
