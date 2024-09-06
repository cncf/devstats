#!/bin/bash
cd /usr/share/grafana.cartography
grafana-server -config /etc/grafana.cartography/grafana.ini cfg:default.paths.data=/var/lib/grafana.cartography 1>/var/log/grafana.cartography.log 2>&1
