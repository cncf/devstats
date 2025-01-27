#!/bin/bash
cd /usr/share/grafana.drasi
grafana-server -config /etc/grafana.drasi/grafana.ini cfg:default.paths.data=/var/lib/grafana.drasi 1>/var/log/grafana.drasi.log 2>&1
