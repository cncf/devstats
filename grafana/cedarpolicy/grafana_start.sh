#!/bin/bash
cd /usr/share/grafana.cedarpolicy
grafana-server -config /etc/grafana.cedarpolicy/grafana.ini cfg:default.paths.data=/var/lib/grafana.cedarpolicy 1>/var/log/grafana.cedarpolicy.log 2>&1
