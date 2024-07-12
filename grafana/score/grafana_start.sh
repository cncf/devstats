#!/bin/bash
cd /usr/share/grafana.score
grafana-server -config /etc/grafana.score/grafana.ini cfg:default.paths.data=/var/lib/grafana.score 1>/var/log/grafana.score.log 2>&1
