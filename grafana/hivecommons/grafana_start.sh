#!/bin/bash
cd /usr/share/grafana.hivecommons
grafana-server -config /etc/grafana.hivecommons/grafana.ini cfg:default.paths.data=/var/lib/grafana.hivecommons 1>/var/log/grafana.hivecommons.log 2>&1
