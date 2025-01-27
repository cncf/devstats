#!/bin/bash
cd /usr/share/grafana.slimfaas
grafana-server -config /etc/grafana.slimfaas/grafana.ini cfg:default.paths.data=/var/lib/grafana.slimfaas 1>/var/log/grafana.slimfaas.log 2>&1
