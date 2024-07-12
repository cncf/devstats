#!/bin/bash
cd /usr/share/grafana.trestlegrc
grafana-server -config /etc/grafana.trestlegrc/grafana.ini cfg:default.paths.data=/var/lib/grafana.trestlegrc 1>/var/log/grafana.trestlegrc.log 2>&1
