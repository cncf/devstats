#!/bin/bash
cd /usr/share/grafana.hwameistor
grafana-server -config /etc/grafana.hwameistor/grafana.ini cfg:default.paths.data=/var/lib/grafana.hwameistor 1>/var/log/grafana.hwameistor.log 2>&1
