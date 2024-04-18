#!/bin/bash
cd /usr/share/grafana.kubean
grafana-server -config /etc/grafana.kubean/grafana.ini cfg:default.paths.data=/var/lib/grafana.kubean 1>/var/log/grafana.kubean.log 2>&1
