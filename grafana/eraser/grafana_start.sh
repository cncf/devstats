#!/bin/bash
cd /usr/share/grafana.eraser
grafana-server -config /etc/grafana.eraser/grafana.ini cfg:default.paths.data=/var/lib/grafana.eraser 1>/var/log/grafana.eraser.log 2>&1
