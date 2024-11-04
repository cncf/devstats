#!/bin/bash
cd /usr/share/grafana.ovnkubernetes
grafana-server -config /etc/grafana.ovnkubernetes/grafana.ini cfg:default.paths.data=/var/lib/grafana.ovnkubernetes 1>/var/log/grafana.ovnkubernetes.log 2>&1
