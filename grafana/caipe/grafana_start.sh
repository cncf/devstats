#!/bin/bash
cd /usr/share/grafana.caipe
grafana-server -config /etc/grafana.caipe/grafana.ini cfg:default.paths.data=/var/lib/grafana.caipe 1>/var/log/grafana.caipe.log 2>&1
