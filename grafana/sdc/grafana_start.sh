#!/bin/bash
cd /usr/share/grafana.sdc
grafana-server -config /etc/grafana.sdc/grafana.ini cfg:default.paths.data=/var/lib/grafana.sdc 1>/var/log/grafana.sdc.log 2>&1
