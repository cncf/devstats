#!/bin/bash
cd /usr/share/grafana.sops
grafana-server -config /etc/grafana.sops/grafana.ini cfg:default.paths.data=/var/lib/grafana.sops 1>/var/log/grafana.sops.log 2>&1
