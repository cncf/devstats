#!/bin/bash
cd /usr/share/grafana.podmancontainertools
grafana-server -config /etc/grafana.podmancontainertools/grafana.ini cfg:default.paths.data=/var/lib/grafana.podmancontainertools 1>/var/log/grafana.podmancontainertools.log 2>&1
