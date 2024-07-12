#!/bin/bash
cd /usr/share/grafana.bankvaults
grafana-server -config /etc/grafana.bankvaults/grafana.ini cfg:default.paths.data=/var/lib/grafana.bankvaults 1>/var/log/grafana.bankvaults.log 2>&1
