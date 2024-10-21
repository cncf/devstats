#!/bin/bash
cd /usr/share/grafana.kusionstack
grafana-server -config /etc/grafana.kusionstack/grafana.ini cfg:default.paths.data=/var/lib/grafana.kusionstack 1>/var/log/grafana.kusionstack.log 2>&1
