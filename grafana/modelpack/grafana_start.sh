#!/bin/bash
cd /usr/share/grafana.modelpack
grafana-server -config /etc/grafana.modelpack/grafana.ini cfg:default.paths.data=/var/lib/grafana.modelpack 1>/var/log/grafana.modelpack.log 2>&1
