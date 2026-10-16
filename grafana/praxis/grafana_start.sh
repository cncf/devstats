#!/bin/bash
cd /usr/share/grafana.praxis
grafana-server -config /etc/grafana.praxis/grafana.ini cfg:default.paths.data=/var/lib/grafana.praxis 1>/var/log/grafana.praxis.log 2>&1
