#!/bin/bash
cd /usr/share/grafana.agentsubstrate
grafana-server -config /etc/grafana.agentsubstrate/grafana.ini cfg:default.paths.data=/var/lib/grafana.agentsubstrate 1>/var/log/grafana.agentsubstrate.log 2>&1
