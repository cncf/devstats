#!/bin/bash
cd /usr/share/grafana.krknchaos
grafana-server -config /etc/grafana.krknchaos/grafana.ini cfg:default.paths.data=/var/lib/grafana.krknchaos 1>/var/log/grafana.krknchaos.log 2>&1
