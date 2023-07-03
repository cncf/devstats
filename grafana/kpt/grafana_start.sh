#!/bin/bash
cd /usr/share/grafana.kpt
grafana-server -config /etc/grafana.kpt/grafana.ini cfg:default.paths.data=/var/lib/grafana.kpt 1>/var/log/grafana.kpt.log 2>&1
