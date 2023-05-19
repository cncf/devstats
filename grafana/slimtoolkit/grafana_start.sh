#!/bin/bash
cd /usr/share/grafana.slimtoolkit
grafana-server -config /etc/grafana.slimtoolkit/grafana.ini cfg:default.paths.data=/var/lib/grafana.slimtoolkit 1>/var/log/grafana.slimtoolkit.log 2>&1
