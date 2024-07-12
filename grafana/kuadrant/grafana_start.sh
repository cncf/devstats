#!/bin/bash
cd /usr/share/grafana.kuadrant
grafana-server -config /etc/grafana.kuadrant/grafana.ini cfg:default.paths.data=/var/lib/grafana.kuadrant 1>/var/log/grafana.kuadrant.log 2>&1
