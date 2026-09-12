#!/bin/bash
# Older name of devel/create_grafana_shared_data.sh (which also builds the Rust binaries shipped in the tar).
exec "$(dirname "$0")/create_grafana_shared_data.sh" "$@"
