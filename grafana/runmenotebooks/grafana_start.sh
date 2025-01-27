#!/bin/bash
cd /usr/share/grafana.runmenotebooks
grafana-server -config /etc/grafana.runmenotebooks/grafana.ini cfg:default.paths.data=/var/lib/grafana.runmenotebooks 1>/var/log/grafana.runmenotebooks.log 2>&1
