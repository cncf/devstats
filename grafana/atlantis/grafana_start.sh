#!/bin/bash
cd /usr/share/grafana.atlantis
grafana-server -config /etc/grafana.atlantis/grafana.ini cfg:default.paths.data=/var/lib/grafana.atlantis 1>/var/log/grafana.atlantis.log 2>&1
