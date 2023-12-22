#!/bin/bash
cd /usr/share/grafana.k8sgpt
grafana-server -config /etc/grafana.k8sgpt/grafana.ini cfg:default.paths.data=/var/lib/grafana.k8sgpt 1>/var/log/grafana.k8sgpt.log 2>&1
