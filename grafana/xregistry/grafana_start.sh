#!/bin/bash
cd /usr/share/grafana.xregistry
grafana-server -config /etc/grafana.xregistry/grafana.ini cfg:default.paths.data=/var/lib/grafana.xregistry 1>/var/log/grafana.xregistry.log 2>&1
