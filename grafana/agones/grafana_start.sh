#!/bin/bash
cd /usr/share/grafana.agones
grafana-server -config /etc/grafana.agones/grafana.ini cfg:default.paths.data=/var/lib/grafana.agones 1>/var/log/grafana.agones.log 2>&1
