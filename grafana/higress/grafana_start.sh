#!/bin/bash
cd /usr/share/grafana.higress
grafana-server -config /etc/grafana.higress/grafana.ini cfg:default.paths.data=/var/lib/grafana.higress 1>/var/log/grafana.higress.log 2>&1
