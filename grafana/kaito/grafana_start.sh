#!/bin/bash
cd /usr/share/grafana.kaito
grafana-server -config /etc/grafana.kaito/grafana.ini cfg:default.paths.data=/var/lib/grafana.kaito 1>/var/log/grafana.kaito.log 2>&1
