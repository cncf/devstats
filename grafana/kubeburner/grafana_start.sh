#!/bin/bash
cd /usr/share/grafana.kubeburner
grafana-server -config /etc/grafana.kubeburner/grafana.ini cfg:default.paths.data=/var/lib/grafana.kubeburner 1>/var/log/grafana.kubeburner.log 2>&1
