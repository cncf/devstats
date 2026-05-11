#!/bin/bash
cd /usr/share/grafana.llmd
grafana-server -config /etc/grafana.llmd/grafana.ini cfg:default.paths.data=/var/lib/grafana.llmd 1>/var/log/grafana.llmd.log 2>&1
