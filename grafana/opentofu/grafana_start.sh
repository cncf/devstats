#!/bin/bash
cd /usr/share/grafana.opentofu
grafana-server -config /etc/grafana.opentofu/grafana.ini cfg:default.paths.data=/var/lib/grafana.opentofu 1>/var/log/grafana.opentofu.log 2>&1
