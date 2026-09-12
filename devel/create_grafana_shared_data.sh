#!/bin/bash
# Creates devstats-grafana.tar - the shared Grafana data (grafana/shared scripts, images, per-project
# customisations, dashboards) plus the DevStats binaries the grafana pods run at start: replacer and sqlitedb
# (grafana/shared/grafana_start.sh) and runq. The binaries are the Rust port (devstatscode/rust) built as static
# Linux musl executables exactly like the "-rust" docker images are built (devstats-docker-images/images/build_rust_bins.sh,
# needs Docker with BuildKit), so the grafana pods run the very same binaries as the CronJobs and the API.
#   ./devel/create_grafana_shared_data.sh
# RUST_BINS=/dir   - take replacer, sqlitedb and runq from that directory instead of building them.
# GO=1             - previous behaviour: Go binaries from ../devstatscode (built there with `make replacer sqlitedb runq`).
# DOCKER_USER=user - name prefix of the intermediate devstats-rust-bins image (default: lukaszgryglicki).
set -o pipefail

if [ -n "${GO}" ]
then
  cp ../devstatscode/sqlitedb ../devstatscode/runq ../devstatscode/replacer grafana/ || exit 1
else
  if [ -z "${RUST_BINS}" ]
  then
    RUST_BINS="../devstats-docker-images/rust-bins"
    DOCKER_USER="${DOCKER_USER:-lukaszgryglicki}" ../devstats-docker-images/images/build_rust_bins.sh "${RUST_BINS}" || exit 1
  fi
  cp "${RUST_BINS}/sqlitedb" "${RUST_BINS}/runq" "${RUST_BINS}/replacer" grafana/ || exit 1
fi

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

tar cf devstats-grafana.tar -T "$tmp" || exit 2

rm -f "$tmp"

ls -lh devstats-grafana.tar
tar tf devstats-grafana.tar | head
