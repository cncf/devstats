#!/bin/bash
cd /usr/share/grafana.loggingoperator
grafana-server -config /etc/grafana.loggingoperator/grafana.ini cfg:default.paths.data=/var/lib/grafana.loggingoperator 1>/var/log/grafana.loggingoperator.log 2>&1
