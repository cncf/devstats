#!/bin/bash
cd /usr/share/grafana.openshell
grafana-server -config /etc/grafana.openshell/grafana.ini cfg:default.paths.data=/var/lib/grafana.openshell 1>/var/log/grafana.openshell.log 2>&1
