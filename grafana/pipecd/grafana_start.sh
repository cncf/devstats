#!/bin/bash
cd /usr/share/grafana.pipecd
grafana-server -config /etc/grafana.pipecd/grafana.ini cfg:default.paths.data=/var/lib/grafana.pipecd 1>/var/log/grafana.pipecd.log 2>&1
