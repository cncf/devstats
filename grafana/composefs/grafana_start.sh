#!/bin/bash
cd /usr/share/grafana.composefs
grafana-server -config /etc/grafana.composefs/grafana.ini cfg:default.paths.data=/var/lib/grafana.composefs 1>/var/log/grafana.composefs.log 2>&1
