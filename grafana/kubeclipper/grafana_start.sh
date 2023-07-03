#!/bin/bash
cd /usr/share/grafana.kubeclipper
grafana-server -config /etc/grafana.kubeclipper/grafana.ini cfg:default.paths.data=/var/lib/grafana.kubeclipper 1>/var/log/grafana.kubeclipper.log 2>&1
