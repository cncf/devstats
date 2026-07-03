cp ../devstatscode/sqlitedb ../devstatscode/runq ../devstatscode/replacer grafana/

tmp="$(mktemp)"

{
  printf '%s\n' \
    grafana/runq \
    grafana/sqlitedb \
    grafana/replacer

  find grafana/shared -type f | sort
  find grafana/img -type f \( -name '*.svg' -o -name '*.png' \) | sort
  find grafana -mindepth 2 -maxdepth 2 -type f \( -name change_title_and_icons.sh -o -name custom_sqlite.sql \) | sort
  find grafana/dashboards -mindepth 2 -maxdepth 2 -type f -name '*.json' | sort
} > "$tmp"

tar cf devstats-grafana.tar -T "$tmp"

rm -f "$tmp"

ls -lh devstats-grafana.tar
tar tf devstats-grafana.tar | head
