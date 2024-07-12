#!/bin/bash
cd /usr/share/grafana.bpfman
grafana-server -config /etc/grafana.bpfman/grafana.ini cfg:default.paths.data=/var/lib/grafana.bpfman 1>/var/log/grafana.bpfman.log 2>&1
