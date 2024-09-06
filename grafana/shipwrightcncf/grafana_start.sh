#!/bin/bash
cd /usr/share/grafana.shipwrightcncf
grafana-server -config /etc/grafana.shipwrightcncf/grafana.ini cfg:default.paths.data=/var/lib/grafana.shipwrightcncf 1>/var/log/grafana.shipwrightcncf.log 2>&1
