#!/bin/bash
cd /usr/share/grafana.tratteria
grafana-server -config /etc/grafana.tratteria/grafana.ini cfg:default.paths.data=/var/lib/grafana.tratteria 1>/var/log/grafana.tratteria.log 2>&1
