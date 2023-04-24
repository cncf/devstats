#!/bin/bash
cd /usr/share/grafana.keycloak
grafana-server -config /etc/grafana.keycloak/grafana.ini cfg:default.paths.data=/var/lib/grafana.keycloak 1>/var/log/grafana.keycloak.log 2>&1
