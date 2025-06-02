#!/bin/bash
cd /usr/share/grafana.urunc
grafana-server -config /etc/grafana.urunc/grafana.ini cfg:default.paths.data=/var/lib/grafana.urunc 1>/var/log/grafana.urunc.log 2>&1
