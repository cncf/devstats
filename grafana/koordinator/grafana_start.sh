#!/bin/bash
cd /usr/share/grafana.koordinator
grafana-server -config /etc/grafana.koordinator/grafana.ini cfg:default.paths.data=/var/lib/grafana.koordinator 1>/var/log/grafana.koordinator.log 2>&1
