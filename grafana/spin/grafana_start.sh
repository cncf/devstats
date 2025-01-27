#!/bin/bash
cd /usr/share/grafana.spin
grafana-server -config /etc/grafana.spin/grafana.ini cfg:default.paths.data=/var/lib/grafana.spin 1>/var/log/grafana.spin.log 2>&1
