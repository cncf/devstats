#!/bin/bash
cd /usr/share/grafana.kubefleet
grafana-server -config /etc/grafana.kubefleet/grafana.ini cfg:default.paths.data=/var/lib/grafana.kubefleet 1>/var/log/grafana.kubefleet.log 2>&1
