#!/bin/bash
cd /usr/share/grafana.openrl
grafana-server -config /etc/grafana.openrl/grafana.ini cfg:default.paths.data=/var/lib/grafana.openrl 1>/var/log/grafana.openrl.log 2>&1
