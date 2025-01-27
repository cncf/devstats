#!/bin/bash
cd /usr/share/grafana.bootc
grafana-server -config /etc/grafana.bootc/grafana.ini cfg:default.paths.data=/var/lib/grafana.bootc 1>/var/log/grafana.bootc.log 2>&1
