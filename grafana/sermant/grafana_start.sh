#!/bin/bash
cd /usr/share/grafana.sermant
grafana-server -config /etc/grafana.sermant/grafana.ini cfg:default.paths.data=/var/lib/grafana.sermant 1>/var/log/grafana.sermant.log 2>&1
