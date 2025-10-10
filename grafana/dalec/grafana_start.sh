#!/bin/bash
cd /usr/share/grafana.dalec
grafana-server -config /etc/grafana.dalec/grafana.ini cfg:default.paths.data=/var/lib/grafana.dalec 1>/var/log/grafana.dalec.log 2>&1
