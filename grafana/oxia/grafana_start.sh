#!/bin/bash
cd /usr/share/grafana.oxia
grafana-server -config /etc/grafana.oxia/grafana.ini cfg:default.paths.data=/var/lib/grafana.oxia 1>/var/log/grafana.oxia.log 2>&1
