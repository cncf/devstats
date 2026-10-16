#!/bin/bash
cd /usr/share/grafana.airunway
grafana-server -config /etc/grafana.airunway/grafana.ini cfg:default.paths.data=/var/lib/grafana.airunway 1>/var/log/grafana.airunway.log 2>&1
