#!/bin/bash
cd /usr/share/grafana.kairos
grafana-server -config /etc/grafana.kairos/grafana.ini cfg:default.paths.data=/var/lib/grafana.kairos 1>/var/log/grafana.kairos.log 2>&1
