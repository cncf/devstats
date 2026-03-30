#!/bin/bash
cd /usr/share/grafana.nmstate
grafana-server -config /etc/grafana.nmstate/grafana.ini cfg:default.paths.data=/var/lib/grafana.nmstate 1>/var/log/grafana.nmstate.log 2>&1
