#!/bin/bash
cd /usr/share/grafana.container2wasm
grafana-server -config /etc/grafana.container2wasm/grafana.ini cfg:default.paths.data=/var/lib/grafana.container2wasm 1>/var/log/grafana.container2wasm.log 2>&1
