export KUBE_CONTEXT=test

source ./migration-functions.sh
preamble devstats-test devel/all_test_dbs.txt
load_fdw_mode

(
  set -euo pipefail

  CHART="${CHART:-../devstats-helm/devstats-helm}"

  if [ ! -f "$CHART/Chart.yaml" ]; then
    echo "ABORT: Helm chart not found: $CHART"
    exit 1
  fi

  echo "Namespace: $NS"
  echo "Chart: $CHART"
  echo "FDW mode: $AFFS_FDW_MODE"

  CJ_OWNERS="/tmp/${NS}-project-cj-owners.tsv"
  RELEASES_FILE="/tmp/${NS}-project-cj-releases.txt"

  kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjobs -o json |
  jq -r '
    .items[]
    | select(.metadata.name != "devstats-affiliations-import")
    | select(
        ((.metadata.labels.type // "") == "cron")
        or
        ((.metadata.labels.type // "") == "affiliations-cron")
      )
    | [
        .metadata.name,
        (.metadata.annotations["meta.helm.sh/release-name"] // "")
      ]
    | @tsv
  ' |
  sort > "$CJ_OWNERS"

  echo "=== Project CronJob owners"
  column -t "$CJ_OWNERS"

  NO_OWNER="$(
    awk -F '\t' '$2 == "" {n++} END {print n+0}' "$CJ_OWNERS"
  )"

  if [ "$NO_OWNER" -ne 0 ]; then
    echo "ABORT: $NO_OWNER project CronJob(s) have no Helm owner:"
    awk -F '\t' '$2 == "" {print $1}' "$CJ_OWNERS"
    exit 1
  fi

  cut -f2 "$CJ_OWNERS" |
  sed '/^$/d' |
  sort -u > "$RELEASES_FILE"

  if [ ! -s "$RELEASES_FILE" ]; then
    echo "ABORT: no project-CronJob-owning Helm releases found"
    exit 1
  fi

  echo "=== Ordinary releases to upgrade"
  cat "$RELEASES_FILE"

  IMPORT_RELEASE="$(
    kubectl --context "$KUBE_CONTEXT" -n "$NS" \
      get cronjob/devstats-affiliations-import \
      -o jsonpath='{.metadata.annotations.meta\.helm\.sh/release-name}'
  )"

  if [ -z "$IMPORT_RELEASE" ]; then
    echo "ABORT: central importer has no Helm release owner"
    exit 1
  fi

  echo "Central importer release, excluded from upgrade loop: $IMPORT_RELEASE"

  if grep -Fxq "$IMPORT_RELEASE" "$RELEASES_FILE"; then
    echo "ABORT: central importer release unexpectedly appears in ordinary release list"
    exit 1
  fi

  AFFS_FDW_USE_PASSWORD=""
  if [ "$AFFS_FDW_MODE" = "password" ]; then
    AFFS_FDW_USE_PASSWORD="1"
  fi

  OVERRIDES="/tmp/affiliations-cutover-${NS}.yaml"

  cat > "$OVERRIDES" <<EOF
affiliationsDB: "affiliations"
checkImportedSHA: ""
affiliationsGetAffsFiles: ""
skipAffiliationsImport: "1"
affsFdwUsePassword: "$AFFS_FDW_USE_PASSWORD"
EOF

  echo "=== Shared-mode overrides"
  cat "$OVERRIDES"

  STAMP="$(date +%Y%m%d-%H%M%S)"
  VALUES_DIR="/tmp/${NS}-affiliations-values-${STAMP}"
  mkdir -p "$VALUES_DIR"

  echo "=== Saving existing release values"

  while IFS= read -r rel; do
    [ -n "$rel" ] || continue

    VALUES_FILE="$VALUES_DIR/$rel.yaml"

    echo "$rel -> $VALUES_FILE"

    helm --kube-context "$KUBE_CONTEXT" -n "$NS" \
      get values "$rel" -o yaml > "$VALUES_FILE"

    # Helm can output "null" when a release has no explicit user values.
    if [ ! -s "$VALUES_FILE" ] ||
       [ "$(tr -d '[:space:]' < "$VALUES_FILE")" = "null" ]; then
      printf '{}\n' > "$VALUES_FILE"
    fi
  done < "$RELEASES_FILE"

  echo "Saved release values in: $VALUES_DIR"

  echo "=== Helm dry-run validation"

  while IFS= read -r rel; do
    [ -n "$rel" ] || continue

    echo "Dry-run: $rel"

    helm --kube-context "$KUBE_CONTEXT" -n "$NS" \
      upgrade "$rel" "$CHART" \
      -f "$VALUES_DIR/$rel.yaml" \
      -f "$OVERRIDES" \
      --dry-run > "/tmp/${NS}-${rel}-affiliations-dry-run.yaml"
  done < "$RELEASES_FILE"

  echo "=== Applying Helm upgrades"

  while IFS= read -r rel; do
    [ -n "$rel" ] || continue

    echo "Upgrading: $rel"

    helm --kube-context "$KUBE_CONTEXT" -n "$NS" \
      upgrade "$rel" "$CHART" \
      -f "$VALUES_DIR/$rel.yaml" \
      -f "$OVERRIDES"
  done < "$RELEASES_FILE"

  echo "=== Confirming central importer ownership did not change"

  CURRENT_IMPORT_RELEASE="$(
    kubectl --context "$KUBE_CONTEXT" -n "$NS" \
      get cronjob/devstats-affiliations-import \
      -o jsonpath='{.metadata.annotations.meta\.helm\.sh/release-name}'
  )"

  if [ "$CURRENT_IMPORT_RELEASE" != "$IMPORT_RELEASE" ]; then
    echo "ABORT: central importer ownership changed:"
    echo "before=$IMPORT_RELEASE"
    echo "after=$CURRENT_IMPORT_RELEASE"
    exit 1
  fi

  echo "Central importer remains owned by: $CURRENT_IMPORT_RELEASE"

  echo "=== Confirming all CronJobs remain suspended"

  UNSUSPENDED="/tmp/${NS}-unexpectedly-unsuspended.txt"

  kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjobs -o json |
  jq -r '
    .items[]
    | select((.spec.suspend // false) != true)
    | .metadata.name
  ' > "$UNSUSPENDED"

  if [ -s "$UNSUSPENDED" ]; then
    echo "These CronJobs became unsuspended; suspending them again:"

    cat "$UNSUSPENDED"

    while IFS= read -r cj; do
      [ -n "$cj" ] || continue

      kubectl --context "$KUBE_CONTEXT" -n "$NS" patch \
        "cronjob/$cj" \
        --type merge \
        -p '{"spec":{"suspend":true}}'
    done < "$UNSUSPENDED"

    echo "ABORT: CronJobs were resuspended; inspect before continuing"
    exit 1
  fi

  echo "OK: all CronJobs remain suspended"

  echo "=== Hourly CronJob shared-DB environment"

  kubectl --context "$KUBE_CONTEXT" -n "$NS" \
    get cronjobs -l type=cron -o json |
  jq -r '
    def env($n):
      (
        [
          .spec.jobTemplate.spec.template.spec.containers[0].env[]?
          | select(.name == $n)
          | .value
        ][0] // "<missing>"
      );

    .items[]
    | [
        .metadata.name,
        env("GHA2DB_AFFILIATIONS_DB")
      ]
    | @tsv
  ' |
  sort |
  column -t

  BAD_SYNC="$(
    kubectl --context "$KUBE_CONTEXT" -n "$NS" \
      get cronjobs -l type=cron -o json |
    jq '
      def env($n):
        (
          [
            .spec.jobTemplate.spec.template.spec.containers[0].env[]?
            | select(.name == $n)
            | .value
          ][0] // "<missing>"
        );

      [
        .items[]
        | select(env("GHA2DB_AFFILIATIONS_DB") != "affiliations")
      ]
      | length
    '
  )"

  if [ "$BAD_SYNC" -ne 0 ]; then
    echo "ABORT: $BAD_SYNC hourly CronJob(s) lack the shared affiliations DB"
    exit 1
  fi

  echo "=== Project affiliation CronJob environment"

  kubectl --context "$KUBE_CONTEXT" -n "$NS" \
    get cronjobs -l type=affiliations-cron -o json |
  jq -r '
    def env($n):
      (
        [
          .spec.jobTemplate.spec.template.spec.containers[0].env[]?
          | select(.name == $n)
          | .value
        ][0] // "<missing>"
      );

    def shown($v):
      if $v == "" then "<empty>" else $v end;

    .items[]
    | [
        .metadata.name,
        shown(env("GHA2DB_AFFILIATIONS_DB")),
        shown(env("GHA2DB_CHECK_IMPORTED_SHA")),
        shown(env("GET_AFFS_FILES"))
      ]
    | @tsv
  ' |
  sort |
  column -t

  BAD_AFFS="$(
    kubectl --context "$KUBE_CONTEXT" -n "$NS" \
      get cronjobs -l type=affiliations-cron -o json |
    jq '
      def env($n):
        (
          [
            .spec.jobTemplate.spec.template.spec.containers[0].env[]?
            | select(.name == $n)
            | .value
          ][0] // "<missing>"
        );

      [
        .items[]
        | select(
            env("GHA2DB_AFFILIATIONS_DB") != "affiliations"
            or env("GHA2DB_CHECK_IMPORTED_SHA") != ""
            or env("GET_AFFS_FILES") != ""
          )
      ]
      | length
    '
  )"

  if [ "$BAD_AFFS" -ne 0 ]; then
    echo "ABORT: $BAD_AFFS project affiliation CronJob(s) have incorrect shared-mode env"
    exit 1
  fi

  echo "OK: all ordinary releases upgraded and verified"
  echo "Saved original user values: $VALUES_DIR"
)
