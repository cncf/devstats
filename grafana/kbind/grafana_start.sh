#!/bin/bash
cd /usr/share/grafana.kbind
grafana-server -config /etc/grafana.kbind/grafana.ini cfg:default.paths.data=/var/lib/grafana.kbind 1>/var/log/grafana.kbind.log 2>&1
