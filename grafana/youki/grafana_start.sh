#!/bin/bash
cd /usr/share/grafana.youki
grafana-server -config /etc/grafana.youki/grafana.ini cfg:default.paths.data=/var/lib/grafana.youki 1>/var/log/grafana.youki.log 2>&1
