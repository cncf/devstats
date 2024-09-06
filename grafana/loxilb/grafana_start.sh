#!/bin/bash
cd /usr/share/grafana.loxilb
grafana-server -config /etc/grafana.loxilb/grafana.ini cfg:default.paths.data=/var/lib/grafana.loxilb 1>/var/log/grafana.loxilb.log 2>&1
