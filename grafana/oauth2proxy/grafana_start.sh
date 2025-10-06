#!/bin/bash
cd /usr/share/grafana.oauth2proxy
grafana-server -config /etc/grafana.oauth2proxy/grafana.ini cfg:default.paths.data=/var/lib/grafana.oauth2proxy 1>/var/log/grafana.oauth2proxy.log 2>&1
