#!/bin/bash
cd /usr/share/grafana.kubestellar
grafana-server -config /etc/grafana.kubestellar/grafana.ini cfg:default.paths.data=/var/lib/grafana.kubestellar 1>/var/log/grafana.kubestellar.log 2>&1
