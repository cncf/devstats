#!/bin/bash
cd /usr/share/grafana.ratify
grafana-server -config /etc/grafana.ratify/grafana.ini cfg:default.paths.data=/var/lib/grafana.ratify 1>/var/log/grafana.ratify.log 2>&1
