#!/bin/bash
cd /usr/share/grafana.apicurioregistry
grafana-server -config /etc/grafana.apicurioregistry/grafana.ini cfg:default.paths.data=/var/lib/grafana.apicurioregistry 1>/var/log/grafana.apicurioregistry.log 2>&1
