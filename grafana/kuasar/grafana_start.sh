#!/bin/bash
cd /usr/share/grafana.kuasar
grafana-server -config /etc/grafana.kuasar/grafana.ini cfg:default.paths.data=/var/lib/grafana.kuasar 1>/var/log/grafana.kuasar.log 2>&1
