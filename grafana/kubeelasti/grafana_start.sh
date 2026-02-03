#!/bin/bash
cd /usr/share/grafana.kubeelasti
grafana-server -config /etc/grafana.kubeelasti/grafana.ini cfg:default.paths.data=/var/lib/grafana.kubeelasti 1>/var/log/grafana.kubeelasti.log 2>&1
