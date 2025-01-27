#!/bin/bash
cd /usr/share/grafana.cloudnativepg
grafana-server -config /etc/grafana.cloudnativepg/grafana.ini cfg:default.paths.data=/var/lib/grafana.cloudnativepg 1>/var/log/grafana.cloudnativepg.log 2>&1
