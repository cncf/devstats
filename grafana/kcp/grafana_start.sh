#!/bin/bash
cd /usr/share/grafana.kcp
grafana-server -config /etc/grafana.kcp/grafana.ini cfg:default.paths.data=/var/lib/grafana.kcp 1>/var/log/grafana.kcp.log 2>&1
