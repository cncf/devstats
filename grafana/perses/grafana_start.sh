#!/bin/bash
cd /usr/share/grafana.perses
grafana-server -config /etc/grafana.perses/grafana.ini cfg:default.paths.data=/var/lib/grafana.perses 1>/var/log/grafana.perses.log 2>&1
