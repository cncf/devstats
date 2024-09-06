#!/bin/bash
cd /usr/share/grafana.carthography
grafana-server -config /etc/grafana.carthography/grafana.ini cfg:default.paths.data=/var/lib/grafana.carthography 1>/var/log/grafana.carthography.log 2>&1
