#!/bin/bash
cd /usr/share/grafana.kuberay
grafana-server -config /etc/grafana.kuberay/grafana.ini cfg:default.paths.data=/var/lib/grafana.kuberay 1>/var/log/grafana.kuberay.log 2>&1
