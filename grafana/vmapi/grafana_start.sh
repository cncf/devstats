#!/bin/bash
cd /usr/share/grafana.vmapi
grafana-server -config /etc/grafana.vmapi/grafana.ini cfg:default.paths.data=/var/lib/grafana.vmapi 1>/var/log/grafana.vmapi.log 2>&1
