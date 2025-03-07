#!/bin/bash
cd /usr/share/grafana.interlink
grafana-server -config /etc/grafana.interlink/grafana.ini cfg:default.paths.data=/var/lib/grafana.interlink 1>/var/log/grafana.interlink.log 2>&1
