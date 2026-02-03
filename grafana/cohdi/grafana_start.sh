#!/bin/bash
cd /usr/share/grafana.cohdi
grafana-server -config /etc/grafana.cohdi/grafana.ini cfg:default.paths.data=/var/lib/grafana.cohdi 1>/var/log/grafana.cohdi.log 2>&1
