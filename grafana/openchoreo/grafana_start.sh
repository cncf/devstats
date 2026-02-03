#!/bin/bash
cd /usr/share/grafana.openchoreo
grafana-server -config /etc/grafana.openchoreo/grafana.ini cfg:default.paths.data=/var/lib/grafana.openchoreo 1>/var/log/grafana.openchoreo.log 2>&1
