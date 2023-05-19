#!/bin/bash
cd /usr/share/grafana.kepler
grafana-server -config /etc/grafana.kepler/grafana.ini cfg:default.paths.data=/var/lib/grafana.kepler 1>/var/log/grafana.kepler.log 2>&1
