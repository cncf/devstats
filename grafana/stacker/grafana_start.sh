#!/bin/bash
cd /usr/share/grafana.stacker
grafana-server -config /etc/grafana.stacker/grafana.ini cfg:default.paths.data=/var/lib/grafana.stacker 1>/var/log/grafana.stacker.log 2>&1
