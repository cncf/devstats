#!/bin/bash
cd /usr/share/grafana.podmandesktop
grafana-server -config /etc/grafana.podmandesktop/grafana.ini cfg:default.paths.data=/var/lib/grafana.podmandesktop 1>/var/log/grafana.podmandesktop.log 2>&1
