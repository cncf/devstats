#!/bin/bash
cp ../devstatscode/sqlitedb ../devstatscode/runq ../devstatscode/replacer grafana/ && tar cf devstats-grafana.tar grafana/runq grafana/sqlitedb grafana/replacer grafana/shared grafana/img/*.svg grafana/img/*.png grafana/*/change_title_and_icons.sh grafana/*/custom_sqlite.sql grafana/dashboards/*/*.json
