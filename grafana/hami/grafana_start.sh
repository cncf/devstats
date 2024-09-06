#!/bin/bash
cd /usr/share/grafana.hami
grafana-server -config /etc/grafana.hami/grafana.ini cfg:default.paths.data=/var/lib/grafana.hami 1>/var/log/grafana.hami.log 2>&1
