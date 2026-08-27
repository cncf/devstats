#!/usr/bin/env bash
#---------------------------------------------------------------------------------------------------------------------
# mega_health_check.sh - the HUGE all-in-one READ-ONLY DevStats infrastructure health probe.
#
# Probes everything we ever probed by hand: k8s API/nodes/pods/events, CronJobs (execution AND log analysis of the
# last job of every CronJob - catches "Completed but with errors inside"), per-project sync freshness vs each
# CronJob's own schedule, sevents_h dashboard coverage, dice (sync_probabilty) skips, affiliations (shared import +
# per-project monthly), flags/locks/1600-column-slots (via devel/devstats-flags-report.sh), Patroni/PostgreSQL
# replication/WAL/connections, PV/PVC placement + storage, git clones presence per project PVC, per-node system
# stats over ssh (disk/inodes/mem/PSI pressures/OOM/failed units/NTP/clock skew/network bandwidth/btrfs device
# errors + recompress cron freshness/load), all ingress hosts HTTPS liveness (grafanas/statics/API/backups page),
# DevStats API Health endpoint, backups presence+freshness (nginx backups page), TLS cert expiries + stuck ACME
# challenges, DNS resolution invariants.
#
# READ ONLY: this script never creates/patches/deletes anything, anywhere. kubectl is only used with
# get/logs/exec(read-only commands: psql SELECT, patronictl list, cat); ssh only runs read-only commands.
#
# Usage (from the devstats repo root, e.g. on the FreeBSD host):
#   ./devel/mega_health_check.sh                 # report only detected issues + summary
#   VERBOSE=1 ./devel/mega_health_check.sh       # also report everything probed (OK lines)
#   DEBUG=1 ./devel/mega_health_check.sh         # VERBOSE + keep raw outputs in artifacts dir + xtrace log
#
# Scope/filtering:
#   STAGES="prod test"        stages to check (default both)
#   ONLY="patroni,web"        run only listed sections
#   SKIP="cjlogs,clones"      skip listed sections
# Sections:
#   tools preflight nodes pods cronjobs cjlogs sync affs flags dblogs patroni storage clones nodesys web backups certs dns
#
# Tunables (env):
#   PAR=16                    parallelism for curl/dns checks       LOGS_PAR=8       parallelism for log scans
#   LOGS_TAIL=2500            log lines fetched per last-job pod    LOGS_MODE=all    all|failed|off
#   SSH_USER=root             NODES="n1 n2"  override node list     SSH_OPTS=...     extra ssh options
#   FRESH_6H_WARN=8 FRESH_6H_CRIT=16     freshness thresholds (hours) for */6 schedules
#   FRESH_DAILY_WARN=27 FRESH_DAILY_CRIT=51   for daily schedules (giants roll 1% dice too)
#   FRESH_MONTHLY_WARN=840    (35d, hours) for monthly schedules (affiliations, backups)
#   SEVENTS_WARN=30           max age (hours) of sevents_h coverage in allprj/gha
#   BACKUP_WARN_DAYS=23       max age of newest backup dump per DB
#   CERT_WARN_DAYS=21 CERT_CRIT_DAYS=7  TLS expiry thresholds
#   DF_WARN=80 DF_CRIT=90     disk usage % thresholds               INODE_WARN=80
#   MEM_WARN=90               node mem usage %                      PODS_MAX=200 PODS_MIN=1  pods per node
#   PSI_CPU_WARN=40 PSI_MEM_WARN=5 PSI_IO_WARN=40   avg60 "some" PSI thresholds
#   LAG_WARN_MB=512           replication/patroni lag               WAL_WARN_GB=64   pg_wal size
#   CONN_WARN_PCT=80          connections vs max_connections        SKEW_WARN=5      clock skew seconds
#   RESTARTS_WARN=50          container restarts                    HTTP_TIMEOUT=15  per-request curl timeout
#   RECOMPRESS_MAX_DAYS=35    max age of last btrfs-recompress run
#   DBLOGS_HOURS=168          gha_logs error-class scan window (hours, default one week)
#   IMPORT_AFFS_WARN=27       max age (hours) of last shared affiliations import log activity
#   KNOWN_DOWN_HOSTS_RE=...   optional: hosts matching this regex report as NOTE instead of WARN/CRIT in web/certs/dns (default: unset - all failures are real issues)
#                             (default: graphql.org family awaiting DNS flip to Linode)
#   ARCHIVED_DBS_RE=...       DB/project names matching this regex are skipped (archived/merged projects)
#
# Exit codes: 0 = all OK, 1 = notices only, 2 = warnings, 3 = criticals.
#---------------------------------------------------------------------------------------------------------------------
set -u
set -o pipefail
export LC_ALL=C

VERBOSE="${VERBOSE:-0}"
DEBUG="${DEBUG:-0}"
[ "$DEBUG" = "1" ] && VERBOSE=1
STAGES="${STAGES:-prod test}"
ONLY="${ONLY:-}"
SKIP="${SKIP:-}"
PAR="${PAR:-16}"
LOGS_PAR="${LOGS_PAR:-8}"
LOGS_TAIL="${LOGS_TAIL:-2500}"
LOGS_MODE="${LOGS_MODE:-all}"
SSH_USER="${SSH_USER:-root}"
SSH_OPTS="${SSH_OPTS:--o ConnectTimeout=6 -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o LogLevel=ERROR}"
FRESH_6H_WARN="${FRESH_6H_WARN:-8}"
FRESH_6H_CRIT="${FRESH_6H_CRIT:-16}"
FRESH_DAILY_WARN="${FRESH_DAILY_WARN:-27}"
FRESH_DAILY_CRIT="${FRESH_DAILY_CRIT:-51}"
FRESH_MONTHLY_WARN="${FRESH_MONTHLY_WARN:-840}"
SEVENTS_WARN="${SEVENTS_WARN:-30}"
BACKUP_WARN_DAYS="${BACKUP_WARN_DAYS:-23}"
CERT_WARN_DAYS="${CERT_WARN_DAYS:-21}"
CERT_CRIT_DAYS="${CERT_CRIT_DAYS:-7}"
DF_WARN="${DF_WARN:-80}"
DF_CRIT="${DF_CRIT:-90}"
INODE_WARN="${INODE_WARN:-80}"
MEM_WARN="${MEM_WARN:-90}"
PODS_MAX="${PODS_MAX:-200}"
PODS_MIN="${PODS_MIN:-1}"
PSI_CPU_WARN="${PSI_CPU_WARN:-40}"
PSI_MEM_WARN="${PSI_MEM_WARN:-5}"
PSI_IO_WARN="${PSI_IO_WARN:-40}"
LAG_WARN_MB="${LAG_WARN_MB:-512}"
WAL_WARN_GB="${WAL_WARN_GB:-64}"
CONN_WARN_PCT="${CONN_WARN_PCT:-80}"
SKEW_WARN="${SKEW_WARN:-5}"
RESTARTS_WARN="${RESTARTS_WARN:-50}"
HTTP_TIMEOUT="${HTTP_TIMEOUT:-15}"
RECOMPRESS_MAX_DAYS="${RECOMPRESS_MAX_DAYS:-35}"
PG_CONTAINER="${PG_CONTAINER:-devstats-postgres}"
PG_USER="${PG_USER:-gha_admin}"
DBLOGS_HOURS="${DBLOGS_HOURS:-168}"
IMPORT_AFFS_WARN="${IMPORT_AFFS_WARN:-27}"
# hosts expected down (graphql.org family awaits DNS flip to Linode; Cloudflare TLS fails until then)
KNOWN_DOWN_HOSTS_RE="${KNOWN_DOWN_HOSTS_RE:-}"
# archived/merged projects (source: devstats:metrics/all/sync_vars.yaml) - skipped wherever they appear
ARCHIVED_DBS_RE="${ARCHIVED_DBS_RE:-^(brigade|smi|openservicemesh|osm|krator|ingraind|fonio|curiefense|krustlet|skooner|k8dash|curve|fabedge|kubedl|superedge|nocalhost|merbridge|devstream|teller|openelb|sealer|cni-genie|cnigenie|servicemeshperformance|xline|pravega|openmetrics|rkt|opentracing|keptn|hexa|hexapolicyorchestrator|vineyard)$}"
known_down() { [ -n "$KNOWN_DOWN_HOSTS_RE" ] && grep -qE "$KNOWN_DOWN_HOSTS_RE" <<<"$1"; }
# first DNS label of an ingress host == project url/db name for project hosts
archived_host() { archived_db "${1%%.*}"; }
archived_db() { grep -qE "$ARCHIVED_DBS_RE" <<<"$1"; }

# ----------------------------------------------------------------------------------------------- output helpers ----
N_OK=0; N_NOTE=0; N_WARN=0; N_CRIT=0
ISSUES=()
CUR_SECTION=""
c_red=""; c_yel=""; c_blu=""; c_grn=""; c_off=""
if [ -t 1 ]; then
  c_red=$(printf '\033[1;31m'); c_yel=$(printf '\033[1;33m'); c_blu=$(printf '\033[1;36m')
  c_grn=$(printf '\033[1;32m'); c_off=$(printf '\033[0m')
fi
section() { CUR_SECTION="$1"; echo; echo "${c_blu}===== [$1] $2 =====${c_off}"; }
ok()   { N_OK=$((N_OK+1));   [ "$VERBOSE" = "1" ] && echo "${c_grn}OK${c_off}    [$CUR_SECTION] $*"; return 0; }
note() { N_NOTE=$((N_NOTE+1)); echo "${c_blu}NOTE${c_off}  [$CUR_SECTION] $*"; ISSUES+=("NOTE  [$CUR_SECTION] $*"); }
warn() { N_WARN=$((N_WARN+1)); echo "${c_yel}WARN${c_off}  [$CUR_SECTION] $*"; ISSUES+=("WARN  [$CUR_SECTION] $*"); }
crit() { N_CRIT=$((N_CRIT+1)); echo "${c_red}CRIT${c_off}  [$CUR_SECTION] $*"; ISSUES+=("CRIT  [$CUR_SECTION] $*"); }
dbg()  { [ "$DEBUG" = "1" ] && echo "DEBUG [$CUR_SECTION] $*" >&2; return 0; }

run_section() {  # run_section <name> -> 0 if section enabled
  local s="$1"
  if [ -n "$ONLY" ]; then
    case ",$ONLY," in *",$s,"*) ;; *) return 1;; esac
  fi
  case ",$SKIP," in *",$s,"*) return 1;; esac
  return 0
}

TMPD="$(mktemp -d /tmp/mega_health.XXXXXX)" || { echo "cannot create tmpdir" >&2; exit 4; }
cleanup() {
  if [ "$DEBUG" = "1" ]; then
    echo; echo "DEBUG: raw artifacts kept in $TMPD"
  else
    rm -rf "$TMPD"
  fi
}
trap cleanup EXIT
[ "$DEBUG" = "1" ] && { exec 9>"$TMPD/xtrace.log"; export BASH_XTRACEFD=9; set -x; }

NOW_EPOCH="$(date +%s)"

# iso2epoch: portable ISO8601 (2026-08-27T07:00:00Z) -> epoch; GNU date then BSD date fallback.
iso2epoch() {
  local t="$1"
  [ -z "$t" ] && { echo 0; return; }
  date -d "$t" +%s 2>/dev/null && return
  date -u -j -f "%Y-%m-%dT%H:%M:%SZ" "$t" +%s 2>/dev/null && return
  echo 0
}
# nginx autoindex date (25-Aug-2026 13:00) -> epoch
ngx2epoch() {
  local t="$1"
  date -d "$t" +%s 2>/dev/null && return
  date -u -j -f "%d-%b-%Y %H:%M" "$t" +%s 2>/dev/null && return
  echo 0
}
age_h() { echo $(( (NOW_EPOCH - $1) / 3600 )); }
hfmt() { local h=$1; if [ "$h" -ge 48 ]; then echo "$((h/24))d$((h%24))h"; else echo "${h}h"; fi; }

# ctx <stage> -> kubectl context args (falls back to current context if named context is absent)
ctx() {
  local st="$1"
  if kubectl config get-contexts -o name 2>/dev/null | grep -qx "$st"; then
    echo "--context $st"
  else
    echo ""
  fi
}
kc() { local st="$1"; shift; kubectl $(ctx "$st") -n "devstats-$st" "$@"; }
kca() { local st="$1"; shift; kubectl $(ctx "$st") "$@"; }

primary_pod() {  # patroni primary pod in stage
  kc "$1" get pods -l role=primary,type=postgres -o jsonpath='{.items[0].metadata.name}' 2>/dev/null
}

# in-pod psql script runner: pipe a bash script via stdin (avoids all quoting/$$-PID pitfalls)
pg_script() {  # pg_script <stage> <pod> < script-on-stdin
  kc "$1" exec -i -c "$PG_CONTAINER" "$2" -- bash -s 2>/dev/null
}

resolve_a() {  # resolve_a <name> -> ALL A records, sorted, comma-joined (host/dig/drill fallbacks)
  local n="$1" out=""
  out="$(host -t A "$n" 2>/dev/null | awk '/has address/{print $NF}' | sort | paste -sd, -)"
  [ -n "$out" ] && { echo "$out"; return; }
  out="$(dig +short A "$n" 2>/dev/null | awk '/^[0-9]/' | sort | paste -sd, -)"
  [ -n "$out" ] && { echo "$out"; return; }
  drill "$n" A 2>/dev/null | awk '$3 == "IN" && $4 == "A" {print $NF}' | sort | paste -sd, -
}

# ------------------------------------------------------------------------------------------------------- tools -----
if run_section tools; then
  section tools "required local tools"
  missing=0
  for t in kubectl jq curl ssh awk openssl; do
    if command -v "$t" >/dev/null 2>&1; then ok "$t present"; else crit "missing required tool: $t"; missing=1; fi
  done
  for t in host dig drill; do command -v "$t" >/dev/null 2>&1 && { ok "resolver tool: $t"; break; }; done
  [ "$missing" = "1" ] && { echo "aborting: install missing tools first" >&2; exit 3; }
  [ -f projects.yaml ] || warn "projects.yaml not found - run from the devstats repo root (clone checks will be limited)"
fi

# --------------------------------------------------------------------------------------------------- preflight -----
declare -A PRIMARY=()
if run_section preflight; then
  section preflight "kubernetes API + contexts + primary PG pods + metrics-server"
  for st in $STAGES; do
    if kca "$st" get --raw /readyz >/dev/null 2>&1; then ok "[$st] apiserver /readyz"; else crit "[$st] apiserver /readyz failed"; fi
    if kca "$st" get --raw /livez >/dev/null 2>&1; then ok "[$st] apiserver /livez"; else warn "[$st] apiserver /livez failed"; fi
    p="$(primary_pod "$st")"
    if [ -n "$p" ]; then PRIMARY[$st]="$p"; ok "[$st] patroni primary pod: $p"; else crit "[$st] cannot resolve patroni primary pod (label role=primary,type=postgres)"; fi
  done
  if kubectl top nodes >/dev/null 2>&1; then ok "metrics-server responds (kubectl top nodes)"; else warn "metrics-server not responding - node/pod usage checks degraded"; fi
fi

# ------------------------------------------------------------------------------------------------------- nodes -----
NODES_LIST="${NODES:-}"
if [ -z "$NODES_LIST" ]; then
  NODES_LIST="$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)"
fi
if run_section nodes; then
  section nodes "node readiness, conditions, versions, usage, pods-per-node"
  kubectl get nodes -o json > "$TMPD/nodes.json" 2>/dev/null
  nnodes="$(jq '.items|length' "$TMPD/nodes.json" 2>/dev/null || echo 0)"
  [ "$nnodes" = "0" ] && crit "no nodes returned by kubectl get nodes"
  while IFS='|' read -r name ready sched kubelet; do
    [ -z "$name" ] && continue
    if [ "$ready" = "True" ]; then ok "node $name Ready (kubelet $kubelet)"; else crit "node $name NOT Ready (Ready=$ready)"; fi
    [ "$sched" = "true" ] && warn "node $name is unschedulable (cordoned)"
  done < <(jq -r '.items[] | "\(.metadata.name)|\((.status.conditions[]|select(.type=="Ready")).status)|\(.spec.unschedulable // false)|\(.status.nodeInfo.kubeletVersion)"' "$TMPD/nodes.json")
  # pressure conditions
  while IFS='|' read -r name cond st; do
    [ "$st" = "True" ] && warn "node $name condition $cond=True"
  done < <(jq -r '.items[] | .metadata.name as $n | .status.conditions[] | select(.type=="MemoryPressure" or .type=="DiskPressure" or .type=="PIDPressure") | "\($n)|\(.type)|\(.status)"' "$TMPD/nodes.json")
  nvers="$(jq -r '.items[].status.nodeInfo.kubeletVersion' "$TMPD/nodes.json" | sort -u | wc -l | tr -d ' ')"
  [ "$nvers" -gt 1 ] && note "kubelet version skew across nodes: $(jq -r '.items[].status.nodeInfo.kubeletVersion' "$TMPD/nodes.json" | sort -u | tr '\n' ' ')" || ok "kubelet versions uniform"
  # usage
  kubectl top nodes --no-headers > "$TMPD/topnodes.txt" 2>/dev/null
  while read -r name cpu cpup mem memp; do
    [ -z "${name:-}" ] && continue
    cpv="${cpup%\%}"; mpv="${memp%\%}"
    if [ "${cpv:-0}" -ge "$MEM_WARN" ] 2>/dev/null; then warn "node $name CPU at $cpup"; else ok "node $name CPU $cpup MEM $memp"; fi
    if [ "${mpv:-0}" -ge "$MEM_WARN" ] 2>/dev/null; then warn "node $name MEM at $memp"; fi
  done < "$TMPD/topnodes.txt"
  # pods per node
  kubectl get pods -A -o json > "$TMPD/allpods.json" 2>/dev/null
  while read -r cnt node; do
    [ -z "${node:-}" ] && continue
    if [ "$cnt" -gt "$PODS_MAX" ]; then warn "node $node runs $cnt pods (> $PODS_MAX)"
    elif [ "$cnt" -lt "$PODS_MIN" ]; then warn "node $node runs only $cnt pods"
    else ok "node $node runs $cnt pods"; fi
  done < <(jq -r '.items[] | select(.status.phase=="Running") | .spec.nodeName' "$TMPD/allpods.json" | sort | uniq -c | awk '{print $1" "$2}')
fi

# -------------------------------------------------------------------------------------------------------- pods -----
if run_section pods; then
  section pods "pod health, restarts, pending PVCs, completed pile-up, warning events"
  [ -f "$TMPD/allpods.json" ] || kubectl get pods -A -o json > "$TMPD/allpods.json" 2>/dev/null
  # non-healthy pods
  bad=0
  while IFS='|' read -r ns name phase reason; do
    [ -z "$name" ] && continue
    bad=$((bad+1))
    warn "pod $ns/$name phase=$phase${reason:+ reason=$reason}"
  done < <(jq -r '.items[] | select(.status.phase != "Running" and .status.phase != "Succeeded") | "\(.metadata.namespace)|\(.metadata.name)|\(.status.phase)|\(.status.reason // "")"' "$TMPD/allpods.json")
  [ "$bad" = "0" ] && ok "no pods outside Running/Succeeded"
  # waiting containers (CrashLoopBackOff etc)
  while IFS='|' read -r ns name reason; do
    [ -z "$name" ] && continue
    warn "pod $ns/$name container waiting: $reason"
  done < <(jq -r '.items[] | select(.status.phase=="Running") | .metadata.namespace as $ns | .metadata.name as $n | (.status.containerStatuses // [])[] | select(.state.waiting != null) | "\($ns)|\($n)|\(.state.waiting.reason)"' "$TMPD/allpods.json")
  # restarts
  while IFS='|' read -r ns name rst; do
    [ -z "$name" ] && continue
    if [ "$rst" -ge "$RESTARTS_WARN" ]; then warn "pod $ns/$name restarts=$rst"; else note "pod $ns/$name restarts=$rst"; fi
  done < <(jq -r --argjson t 20 '.items[] | .metadata.namespace as $ns | .metadata.name as $n | (.status.containerStatuses // [])[] | select(.restartCount >= $t) | "\($ns)|\($n)|\(.restartCount)"' "$TMPD/allpods.json")
  # succeeded pile per namespace
  while read -r cnt ns; do
    [ -z "${ns:-}" ] && continue
    if [ "$cnt" -gt 300 ]; then note "$ns has $cnt Completed pods (pile-up)"; else ok "$ns Completed pods: $cnt"; fi
  done < <(jq -r '.items[] | select(.status.phase=="Succeeded") | .metadata.namespace' "$TMPD/allpods.json" | sort | uniq -c | awk '{print $1" "$2}')
  # pending PVCs
  kubectl get pvc -A -o json > "$TMPD/pvcs.json" 2>/dev/null
  pend=0
  while IFS='|' read -r ns name ph; do
    [ -z "$name" ] && continue
    [ "$ph" = "Bound" ] && continue
    pend=$((pend+1)); warn "PVC $ns/$name phase=$ph"
  done < <(jq -r '.items[] | "\(.metadata.namespace)|\(.metadata.name)|\(.status.phase)"' "$TMPD/pvcs.json")
  [ "$pend" = "0" ] && ok "all PVCs Bound ($(jq '.items|length' "$TMPD/pvcs.json"))"
  # recent warning events (2h)
  kubectl get events -A -o json > "$TMPD/events.json" 2>/dev/null
  ev="$(jq -r --argjson now "$NOW_EPOCH" '[.items[] | select(.type=="Warning") | (.lastTimestamp // .eventTime // .metadata.creationTimestamp) as $t | select($t != null)] | length' "$TMPD/events.json" 2>/dev/null || echo 0)"
  recent="$(jq -r '[.items[] | select(.type=="Warning")] | group_by(.reason) | map({r: .[0].reason, c: length}) | sort_by(-.c) | .[0:8][] | "\(.r)=\(.c)"' "$TMPD/events.json" 2>/dev/null | tr '\n' ' ')"
  if [ "${ev:-0}" -gt 0 ]; then note "warning events present: $ev (reasons: $recent)"; else ok "no warning events"; fi
fi

# ---------------------------------------------------------------------------------------------------- cronjobs -----
# collects per-stage: cj list json, latest job per cj, schedules; used also by sync/affs/cjlogs sections
declare -A CJJSON=() JOBSJSON=()
# json list fetch with retries - single http2 drops must not silently yield empty lists
kcj() {  # kcj <stage> <outfile> <kubectl-get-args...> -> 0 on valid json with .items
  local st="$1" out="$2" try; shift 2
  for try in 1 2 3; do
    if kc "$st" get "$@" -o json > "$out" 2>/dev/null && jq -e '.items' "$out" >/dev/null 2>&1; then
      return 0
    fi
    dbg "kcj retry $try failed: $st get $*"
    sleep 2
  done
  echo '{"items":[]}' > "$out"
  return 1
}
collect_cj() {
  local st="$1"
  [ -n "${CJJSON[$st]:-}" ] && return
  kcj "$st" "$TMPD/cj-$st.json" cj || warn "[$st] listing CronJobs failed after 3 attempts (flaky API?) - dependent checks incomplete"
  kcj "$st" "$TMPD/jobs-$st.json" jobs || warn "[$st] listing Jobs failed after 3 attempts (flaky API?) - dependent checks incomplete"
  CJJSON[$st]="$TMPD/cj-$st.json"; JOBSJSON[$st]="$TMPD/jobs-$st.json"
  # latest job per owning CJ: cj|job|active|succeeded|failed|start|completion
  jq -r '.items[] | select((.metadata.ownerReferences // []) | length > 0) |
    "\(.metadata.ownerReferences[0].name)|\(.metadata.name)|\(.status.active // 0)|\(.status.succeeded // 0)|\(.status.failed // 0)|\(.status.startTime // "")|\(.status.completionTime // "")|\(.metadata.creationTimestamp)"' \
    "$TMPD/jobs-$st.json" | sort -t'|' -k1,1 -k8,8 | awk -F'|' '{last[$1]=$0} END{for (k in last) print last[k]}' > "$TMPD/lastjob-$st.txt"
  # schedule map
  jq -r '.items[] | "\(.metadata.name)|\(.spec.schedule)|\(.spec.suspend // false)|\(.status.lastScheduleTime // "")|\(.status.lastSuccessfulTime // "")|\(.metadata.creationTimestamp)"' "$TMPD/cj-$st.json" > "$TMPD/cjsched-$st.txt"
}
# schedule -> max expected interval hours (heuristic: */N hours -> N, fixed daily -> 24, DOM-based -> monthly)
sched_interval_h() {
  local sched="$1" min hr dom
  min="$(echo "$sched" | awk '{print $1}')"; hr="$(echo "$sched" | awk '{print $2}')"; dom="$(echo "$sched" | awk '{print $3}')"
  case "$hr" in
    \*/*) echo "${hr#*/}"; return;;
    \*) echo 1; return;;
  esac
  case "$dom" in
    \*) echo 24; return;;
    *) echo 744; return;;   # DOM-restricted -> monthly-ish
  esac
}
if run_section cronjobs; then
  section cronjobs "suspends, missed schedules, stuck active jobs, orphan manual jobs"
  for st in $STAGES; do
    collect_cj "$st"
    ncj="$(jq '.items|length' "${CJJSON[$st]}")"
    ok "[$st] $ncj CronJobs inventoried"
    while IFS='|' read -r name sched susp lastsched lastok created; do
      [ -z "$name" ] && continue
      [ "$susp" = "true" ] && warn "[$st] CronJob $name is SUSPENDED"
      iv="$(sched_interval_h "$sched")"
      if [ -n "$lastsched" ]; then
        a=$(age_h "$(iso2epoch "$lastsched")")
        if [ "$a" -gt $((iv*2+2)) ]; then
          warn "[$st] CronJob $name missed schedules: lastScheduleTime $(hfmt $a) ago (interval ${iv}h, schedule '$sched')"
        else
          ok "[$st] CronJob $name scheduling on time (last $(hfmt $a) ago, '$sched')"
        fi
      else
        cage=$(age_h "$(iso2epoch "$created")")
        if [ "$cage" -gt $((iv+2)) ]; then
          warn "[$st] CronJob $name NEVER scheduled although $(hfmt $cage) old (interval ${iv}h, schedule '$sched')"
        else
          ok "[$st] CronJob $name not due yet (CJ $(hfmt $cage) old, interval ${iv}h)"
        fi
      fi
    done < "$TMPD/cjsched-$st.txt"
    # stuck active jobs > 48h
    while IFS='|' read -r cj job active succ fail start compl created; do
      [ -z "$cj" ] && continue
      if [ "$active" -gt 0 ] && [ -n "$start" ]; then
        a=$(age_h "$(iso2epoch "$start")")
        [ "$a" -ge 48 ] && warn "[$st] job $job (CJ $cj) still ACTIVE after $(hfmt $a)"
      fi
    done < "$TMPD/lastjob-$st.txt"
    # orphan (non-CJ-owned) jobs older than 2 days
    while IFS='|' read -r job created; do
      [ -z "$job" ] && continue
      a=$(age_h "$(iso2epoch "$created")")
      [ "$a" -ge 48 ] && note "[$st] standalone job $job is $(hfmt $a) old (manual leftover?)"
    done < <(jq -r '.items[] | select((.metadata.ownerReferences // []) | length == 0) | "\(.metadata.name)|\(.metadata.creationTimestamp)"' "${JOBSJSON[$st]}")
  done
fi

# ------------------------------------------------------------------------------------------------------ cjlogs -----
# The deep probe: for the LAST job of every CronJob - status + full log-pattern analysis.
# Catches the "Completed but 'There were sync errors' inside" hidden failure mode.
if run_section cjlogs && [ "$LOGS_MODE" != "off" ]; then
  section cjlogs "last-job log analysis of every CronJob (patterns: panics, sync errors, fatals, dice skips)"
  for st in $STAGES; do
    collect_cj "$st"
    if [ ! -s "$TMPD/lastjob-$st.txt" ]; then
      warn "[$st] cjlogs: collected 0 jobs (API hiccup or empty namespace) - nothing scanned for $st"
      continue
    fi
    kcj "$st" "$TMPD/pods-$st.json" pods || warn "[$st] cjlogs: listing pods failed after 3 attempts - job->pod log mapping incomplete"
    # map job -> newest pod name + phase
    jq -r '.items[] | select(.metadata.labels["job-name"] != null) | "\(.metadata.labels["job-name"])|\(.metadata.name)|\(.status.phase)|\(.metadata.creationTimestamp)"' \
      "$TMPD/pods-$st.json" | sort -t'|' -k1,1 -k4,4 | awk -F'|' '{last[$1]=$2"|"$3} END{for (k in last) print k"|"last[k]}' > "$TMPD/jobpod-$st.txt"
    mkdir -p "$TMPD/logs-$st"
    : > "$TMPD/logjobs-$st.txt"
    while IFS='|' read -r cj job active succ fail start compl created; do
      [ -z "$cj" ] && continue
      if [ "$fail" -gt 0 ]; then
        if [ "${succ:-0}" -gt 0 ]; then
          note "[$st] CJ $cj: last job $job succeeded after $fail failed pod attempt(s)"
        elif [ "${active:-0}" -gt 0 ]; then
          warn "[$st] CJ $cj: last job $job still retrying (failed=$fail, active=$active)"
        else
          crit "[$st] CJ $cj: last job $job FAILED (failed=$fail, no success)"
        fi
      fi
      [ "$LOGS_MODE" = "failed" ] && [ "$fail" = "0" ] && continue
      pline="$(grep "^$job|" "$TMPD/jobpod-$st.txt" || true)"
      [ -z "$pline" ] && { ok "[$st] CJ $cj: last job $job has no pod (GC-ed) - no log to scan"; continue; }
      pod="$(echo "$pline" | cut -d'|' -f2)"
      echo "$cj|$job|$pod" >> "$TMPD/logjobs-$st.txt"
    done < "$TMPD/lastjob-$st.txt"
    njobs="$(wc -l < "$TMPD/logjobs-$st.txt" | tr -d ' ')"
    ok "[$st] scanning logs of $njobs last-jobs (tail $LOGS_TAIL each, ${LOGS_PAR}x parallel)"
    # parallel fetch
    export TMPD LOGS_TAIL
    while IFS='|' read -r cj job pod; do
      printf '%s\0' "$st|$cj|$pod"
    done < "$TMPD/logjobs-$st.txt" | xargs -0 -n1 -P "$LOGS_PAR" bash -c '
      IFS="|" read -r st cj pod <<< "$0"
      kubectl --context "$st" -n "devstats-$st" logs "$pod" --tail="$LOGS_TAIL" > "$TMPD/logs-$st/$cj.log" 2>/dev/null || true
    ' 2>/dev/null
    # scan
    while IFS='|' read -r cj job pod; do
      lf="$TMPD/logs-$st/$cj.log"
      [ -s "$lf" ] || { note "[$st] CJ $cj: empty/unreadable log ($pod)"; continue; }
      crits="$(grep -cE 'panic:|fatal error:|There were sync errors|Error updating git repos' "$lf" || true)"
      warns="$(grep -cE 'FATAL:|driver: bad connection|command failed|exit status [1-9]' "$lf" || true)"
      dice="$(grep -cE '^([0-9: -]+/devstats: )?Skipping #[0-9]+ ' "$lf" || true)"
      guard="$(grep -cE 'Running flag on .* set, exiting|Not all databases provisioned, pending: [0-9]+, exiting' "$lf" || true)"
      if [ "${guard:-0}" -gt 0 ]; then
        # overlap/provision-guard exit: 'There were sync errors' emitted by design when refusing to run
        # (another sync holds the running flag, or an affs-import/provisioning window cleared 'provisioned')
        se="$(grep -cE 'There were sync errors' "$lf" || true)"
        crits=$(( crits - se )); [ "$crits" -lt 0 ] && crits=0
        ok "[$st] CJ $cj: overlap/provision-guard exit (another sync or affs-import owns the DB) in last run"
      fi
      if [ "${crits:-0}" -gt 0 ]; then
        crit "[$st] CJ $cj: log has $crits critical error line(s); first: $(grep -m1 -E 'panic:|fatal error:|There were sync errors|Error updating git repos' "$lf" | head -c 220)"
      elif [ "${warns:-0}" -gt 0 ]; then
        warn "[$st] CJ $cj: log has $warns error-ish line(s); first: $(grep -m1 -E 'FATAL:|driver: bad connection|command failed|exit status [1-9]' "$lf" | head -c 220)"
      else
        ok "[$st] CJ $cj: log clean ($job)"
      fi
      [ "${dice:-0}" -gt 0 ] && ok "[$st] CJ $cj: sync_probabilty dice skip in last run ($(grep -m1 -E 'Skipping #[0-9]+' "$lf" | head -c 120))"
    done < "$TMPD/logjobs-$st.txt"
  done
fi

# -------------------------------------------------------------------------------------------------------- sync -----
# Per-project DB freshness (gha_last_computed) vs each project CronJob's own schedule + sevents_h coverage.
if run_section sync; then
  section sync "per-project sync freshness (gha_last_computed vs schedule) + dashboards coverage (sevents_h)"
  for st in $STAGES; do
    collect_cj "$st"
    p="${PRIMARY[$st]:-$(primary_pod "$st")}"
    [ -z "$p" ] && { crit "[$st] no primary PG pod - skipping freshness"; continue; }
    # build project|db|interval list from sync CJs (devstats-<proj>, not affiliations/backups/import)
    : > "$TMPD/freshlist-$st.txt"
    while IFS='|' read -r name sched susp lastsched lastok created; do
      case "$name" in
        devstats-affiliations-*|devstats-backups|devstats-affiliations) continue;;
        devstats-*) proj="${name#devstats-}";;
        *) continue;;
      esac
      db="$proj"
      [ "$proj" = "kubernetes" ] && db="gha"
      [ "$proj" = "all" ] && db="allprj"
      echo "$db|$(sched_interval_h "$sched")" >> "$TMPD/freshlist-$st.txt"
    done < "$TMPD/cjsched-$st.txt"
    nf="$(wc -l < "$TMPD/freshlist-$st.txt" | tr -d ' ')"
    ok "[$st] checking freshness of $nf project DBs (single in-pod pass)"
    # generate in-pod script (avoids quoting pitfalls; runs read-only SELECTs)
    {
      echo 'while IFS="|" read -r db iv; do'
      echo "  v=\$(psql -U $PG_USER -d \"\$db\" -tAc 'select coalesce(extract(epoch from now() - max(dt))::bigint, -1) from gha_last_computed' 2>/dev/null </dev/null)"
      echo '  echo "$db|$iv|${v:-err}"'
      echo 'done <<EOF_LIST'
      cat "$TMPD/freshlist-$st.txt"
      echo 'EOF_LIST'
    } > "$TMPD/freshscript-$st.sh"
    pg_script "$st" "$p" < "$TMPD/freshscript-$st.sh" > "$TMPD/freshout-$st.txt"
    while IFS='|' read -r db iv secs; do
      [ -z "$db" ] && continue
      case "$secs" in ''|err|*[!0-9-]*) warn "[$st] $db: cannot read gha_last_computed"; continue;; esac
      [ "$secs" = "-1" ] && { warn "[$st] $db: gha_last_computed is empty"; continue; }
      h=$((secs/3600))
      if [ "$iv" -le 6 ]; then w=$FRESH_6H_WARN; c=$FRESH_6H_CRIT
      elif [ "$iv" -le 24 ]; then w=$FRESH_DAILY_WARN; c=$FRESH_DAILY_CRIT
      else w=$FRESH_MONTHLY_WARN; c=$((FRESH_MONTHLY_WARN*2)); fi
      if [ "$h" -ge "$c" ]; then crit "[$st] $db sync STALE: last computed $(hfmt $h) ago (cadence ${iv}h)"
      elif [ "$h" -ge "$w" ]; then warn "[$st] $db sync stale: last computed $(hfmt $h) ago (cadence ${iv}h)"
      else ok "[$st] $db fresh: $(hfmt $h) ago (cadence ${iv}h)"; fi
    done < "$TMPD/freshout-$st.txt"
    # sevents_h coverage for the two dashboard-critical DBs (prod only has them)
    if [ "$st" = "prod" ]; then
      {
        echo "for db in allprj gha; do"
        echo "  v=\$(psql -U $PG_USER -d \"\$db\" -tAc 'select coalesce(extract(epoch from now() - max(time))::bigint, -1) from sevents_h' 2>/dev/null </dev/null)"
        echo '  echo "$db|${v:-err}"'
        echo "done"
      } | pg_script "$st" "$p" > "$TMPD/sevents-$st.txt"
      while IFS='|' read -r db secs; do
        case "$secs" in ''|err|*[!0-9-]*) note "[$st] $db: no sevents_h readable"; continue;; esac
        h=$((secs/3600))
        if [ "$h" -ge "$SEVENTS_WARN" ]; then warn "[$st] $db dashboards data (sevents_h) ends $(hfmt $h) ago"
        else ok "[$st] $db dashboards data (sevents_h) current to $(hfmt $h) ago"; fi
      done < "$TMPD/sevents-$st.txt"
    fi
  done
fi

# -------------------------------------------------------------------------------------------------------- affs -----
if run_section affs; then
  section affs "shared affiliations import + per-project monthly affiliations CJs"
  for st in $STAGES; do
    collect_cj "$st"
    # shared import (prod: devstats-affiliations-import, daily)
    line="$(grep '^devstats-affiliations-import|' "$TMPD/cjsched-$st.txt" || true)"
    if [ -n "$line" ]; then
      lastok="$(echo "$line" | cut -d'|' -f5)"
      created="$(echo "$line" | cut -d'|' -f6)"
      if [ -n "$lastok" ]; then
        a=$(age_h "$(iso2epoch "$lastok")")
        if [ "$a" -gt 51 ]; then warn "[$st] affiliations-import last SUCCESS $(hfmt $a) ago"; else ok "[$st] affiliations-import last success $(hfmt $a) ago"; fi
      elif [ "$(age_h "$(iso2epoch "$created")")" -gt 26 ]; then
        warn "[$st] affiliations-import never succeeded although CJ is $(hfmt $(age_h "$(iso2epoch "$created")")) old"
      else
        ok "[$st] affiliations-import not due yet"
      fi
    fi
    # per-project affiliations: monthly - check lastSuccessfulTime < 35d
    stale=0; total=0
    while IFS='|' read -r name sched susp lastsched lastok created; do
      case "$name" in devstats-affiliations-import|devstats-affiliations) continue;; devstats-affiliations-*) ;; *) continue;; esac
      total=$((total+1))
      proj="${name#devstats-affiliations-}"
      if [ -n "$lastok" ]; then
        a=$(age_h "$(iso2epoch "$lastok")")
        if [ "$a" -gt "$FRESH_MONTHLY_WARN" ]; then stale=$((stale+1)); warn "[$st] affiliations-$proj last success $(hfmt $a) ago (> $(hfmt $FRESH_MONTHLY_WARN))"; else ok "[$st] affiliations-$proj $(hfmt $a) ago"; fi
      else
        cage=$(age_h "$(iso2epoch "$created")")
        if [ "$cage" -gt "$FRESH_MONTHLY_WARN" ]; then
          stale=$((stale+1)); warn "[$st] affiliations-$proj NEVER succeeded although CJ is $(hfmt $cage) old"
        else
          ok "[$st] affiliations-$proj not due yet (CJ $(hfmt $cage) old, monthly)"
        fi
      fi
    done < "$TMPD/cjsched-$st.txt"
    [ "$total" -gt 0 ] && ok "[$st] per-project affiliations CJs checked: $total (stale: $stale)"
  done
fi

# ------------------------------------------------------------------------------------------------------- flags -----
if run_section flags; then
  section flags "provisioned/devstats_running/locks/deadlocks/blocked-sessions/1600-column-slots (devstats-flags-report.sh)"
  if [ -x devel/devstats-flags-report.sh ]; then
    for st in $STAGES; do
      out="$TMPD/flags-$st.txt"
      if DEBUG=0 ./devel/devstats-flags-report.sh "$st" > "$out" 2>&1; then
        ok "[$st] flags report: OK ($(grep -c '' "$out") lines)"
      else
        rc=$?
        missp="$(awk '/DBs missing .provisioned./{f=1;next} /^$|^==/{f=0} f && /^  - /{printf "%s ", $2}' "$out")"
        crit "[$st] flags report NOT OK (rc=$rc): $(sed -n '/^NOT OK/,$p' "$out" | tr '\n' '; ' | head -c 300)${missp:+ [missing provisioned: ${missp% }]}"
      fi
      [ "$VERBOSE" = "1" ] && sed 's/^/      | /' "$out" | tail -40
    done
  else
    warn "devel/devstats-flags-report.sh not found/executable - flags checks skipped (run from devstats repo root)"
  fi
fi

# ------------------------------------------------------------------------------------------------------ dblogs -----
# deep scan of gha_logs (devstats DB) for every error class observed so far + devstats/affiliations DB sanity
if run_section dblogs; then
  section dblogs "gha_logs error-class scan (${DBLOGS_HOURS}h) + devstats gha_computed/gha_locks + affiliations DB deep sanity"
  for st in $STAGES; do
    p="${PRIMARY[$st]:-$(primary_pod "$st")}"
    [ -z "$p" ] && { crit "[$st] no primary PG pod - dblogs skipped"; continue; }
    f="$TMPD/dblogs-$st.txt"
    {
      echo "psql -U $PG_USER -d devstats -tA -F'|' <<'SQL'"
      echo "with w as ("
      echo "  select proj, prog, dt, run_dt, msg,"
      echo "    case"
      echo "      when msg like '%panic:%' or msg like '%fatal error:%' or msg like '%stacktrace:%' or msg like '%Stacktrace:%' or msg like '%Error(time=%' then 'panic'"
      echo "      when msg like '%There were sync errors%' then 'sync_errors'"
      echo "      when msg like '%Error updating git repos%' then 'git_repos_error'"
      echo "      when msg like '%Error executing ghapi2db%' then 'ghapi2db_error'"
      echo "      when msg like '%Error running git_commits.sh%' or msg like '%git_commits.sh error%' then 'git_commits_error'"
      echo "      when msg like '%Error committing transaction%' then 'tx_commit_error'"
      echo "      when msg like '%Failing batch insert%' or msg like '%Failed sql%' or msg like '%Failed command%' or msg like '%Failing values%' then 'sql_fail'"
      echo "      when msg like '%PqError: code=%' then 'pq_error'"
      echo "      when msg like '%driver: bad connection%' then 'bad_connection'"
      echo "      when msg like '%too many connections%' or msg like '%too_many_connections%' then 'too_many_connections'"
      echo "      when msg like '%cannot_connect_now%' or msg like '%DB shutting down%' then 'db_shutdown'"
      echo "      when msg like '%cannot assign requested address%' then 'addr_exhaustion'"
      echo "      when msg like '%deadlock detected%' then 'deadlock'"
      echo "      when msg like '%connection refused%' or msg like '%connection reset%' then 'connection_refused_reset'"
      echo "      when msg like '%context deadline exceeded%' then 'context_deadline'"
      echo "      when msg like '%FATAL:%' then 'pg_fatal'"
      echo "      when (msg like '%API limit reached%' or msg like '%abuse detected%' or msg ilike '%rate limit%') and (msg like '%abort%' or msg like '%want to wait%') then 'gh_api_abort'"
      echo "      when msg like '%API limit reached%' or msg like '%abuse detected%' or msg ilike '%rate limit%' or msg like '%GetRateLimit call failed%' then 'gh_rate_limit'"
      echo "      when msg like '%timeout signal after%' then 'timeout_kill'"
      echo "      when msg like '%Failed to clear running flag%' then 'flag_clear_fail'"
      echo "      when msg like '%Missing provisioned flag%' or msg like '%Not all databases provisioned%' then 'provision_guard'"
      echo "      when msg like '%cannot check running flag%' or msg like '%cannot set running flag%' then 'flag_missing'"
      echo "      when msg like '%Running flag on%set, exiting%' or msg like '%instance is running, PID file%' then 'overlap_guard'"
      echo "      when msg like '%Skipping #%' then 'dice_skip'"
      echo "      when msg like '%Metric returned no data%' then 'metric_no_data'"
      echo "      when msg like '%Cannot unmarshal%' or msg like '%Unmarshal failed%' or msg like '%Error http.Get%' then 'http_json_error'"
      echo "      when (msg like '%hash id%' or msg like '%orphan event id%') and msg like '%conflict%' then 'data_conflict'"
      echo "      when msg like '%Error (non fatal)%' or msg like '%(ignored)%' or msg like '%non fatal, exiting 0%' then 'nonfatal_error'"
      echo "      when msg like '%Warning:%' or msg like '%warning:%' then 'go_warning'"
      echo "      when msg like '%gitListCommits failed%' then 'git_noise'"
      echo "      when msg like '%exit status%' then 'exit_status'"
      echo "      when msg ilike '%error%' and msg not ilike '%0 errors%' and msg not ilike '%errors=0%' then 'generic_error'"
      echo "    end as class"
      echo "  from gha_logs where dt > now() - interval '${DBLOGS_HOURS} hours'"
      echo ")"
      echo "select 'cnt', class, cnt, mn, mx, sample from ("
      echo "  select class,"
      echo "    count(*) over (partition by class) as cnt,"
      echo "    to_char(min(dt) over (partition by class), 'YYYY-MM-DD HH24:MI:SS') as mn,"
      echo "    to_char(max(dt) over (partition by class), 'YYYY-MM-DD HH24:MI:SS') as mx,"
      echo "    proj || ' @ ' || to_char(dt, 'YYYY-MM-DD HH24:MI:SS') || ': ' || left(replace(msg, E'\n', ' '), 180) as sample,"
      echo "    row_number() over (partition by class order by dt desc) as rn"
      echo "  from w where class is not null"
      echo ") x where rn = 1;"
      echo "SQL"
    } | pg_script "$st" "$p" > "$f" || true
    # counts per class -> severity (row: cnt|class|N|firstdt|lastdt|sample)
    while IFS='|' read -r tag class cntv firstdt lastdt smp; do
      [ "$tag" = "cnt" ] || continue
      span="between $firstdt and $lastdt"
      case "$class" in
        panic)                    crit "[$st] gha_logs: $cntv panic/stacktrace/fatal-error line(s), $span; sample: $smp";;
        sync_errors)              warn "[$st] gha_logs: $cntv 'There were sync errors' line(s), $span (overlap/provision-guard exits also emit this); sample: $smp";;
        git_repos_error)          warn "[$st] gha_logs: $cntv git-repos update error(s), $span; sample: $smp";;
        ghapi2db_error)           warn "[$st] gha_logs: $cntv ghapi2db execution error(s), $span; sample: $smp";;
        git_commits_error)        warn "[$st] gha_logs: $cntv git_commits.sh error(s), $span; sample: $smp";;
        tx_commit_error)          warn "[$st] gha_logs: $cntv transaction commit error(s), $span; sample: $smp";;
        sql_fail)                 warn "[$st] gha_logs: $cntv failed SQL/batch-insert/command line(s), $span; sample: $smp";;
        pq_error)                 warn "[$st] gha_logs: $cntv PqError line(s), $span; sample: $smp";;
        bad_connection)           warn "[$st] gha_logs: $cntv 'driver: bad connection' line(s), $span; sample: $smp";;
        too_many_connections)     warn "[$st] gha_logs: $cntv 'too many connections' line(s), $span; sample: $smp";;
        db_shutdown)              warn "[$st] gha_logs: $cntv DB-shutting-down line(s), $span; sample: $smp";;
        addr_exhaustion)          warn "[$st] gha_logs: $cntv 'cannot assign requested address' line(s) (ephemeral port/conn exhaustion), $span; sample: $smp";;
        deadlock)                 warn "[$st] gha_logs: $cntv deadlock(s) detected, $span; sample: $smp";;
        connection_refused_reset) warn "[$st] gha_logs: $cntv connection refused/reset line(s), $span; sample: $smp";;
        context_deadline)         warn "[$st] gha_logs: $cntv context-deadline-exceeded line(s), $span; sample: $smp";;
        pg_fatal)                 warn "[$st] gha_logs: $cntv PG FATAL line(s), $span; sample: $smp";;
        gh_api_abort)             warn "[$st] gha_logs: $cntv GitHub-API abort(s) (tokens fully exhausted, gave up), $span; sample: $smp";;
        gh_rate_limit)            ok "[$st] gha_logs: $cntv GitHub abuse/rate-limit line(s) (self-healing token switch/waits), $span";;
        timeout_kill)             warn "[$st] gha_logs: $cntv program-timeout kill(s) ('timeout signal after'), $span; sample: $smp";;
        flag_clear_fail)          warn "[$st] gha_logs: $cntv running-flag clear failure(s), $span; sample: $smp";;
        provision_guard)          ok "[$st] gha_logs: $cntv provision-guard line(s) (benign: affs-import/provisioning window; flags section checks current state), $span";;
        flag_missing)             warn "[$st] gha_logs: $cntv running-flag check/set problem line(s), $span; sample: $smp";;
        overlap_guard)            ok "[$st] gha_logs: $cntv overlap-guard exit(s) (benign: sync already running), $span";;
        dice_skip)                ok "[$st] gha_logs: $cntv sync_probabilty dice skip(s), $span";;
        metric_no_data)           ok "[$st] gha_logs: $cntv 'Metric returned no data' line(s) (usually benign), $span";;
        http_json_error)          warn "[$st] gha_logs: $cntv HTTP-get/JSON-unmarshal error(s), $span; sample: $smp";;
        data_conflict)            note "[$st] gha_logs: $cntv artificial/orphan event id conflict(s) (skipped rows), $span";;
        nonfatal_error)           note "[$st] gha_logs: $cntv explicitly non-fatal/ignored error line(s), $span";;
        go_warning)               note "[$st] gha_logs: $cntv 'Warning:' line(s) (mixed benign classes), $span";;
        git_noise)                ok "[$st] gha_logs: $cntv gitListCommits-failed line(s) (normal git noise), $span";;
        exit_status)              warn "[$st] gha_logs: $cntv 'exit status' line(s), $span; sample: $smp";;
        generic_error)            note "[$st] gha_logs: $cntv other error-ish line(s), $span; sample: $smp";;
      esac
    done < <(grep '^cnt|' "$f" || true)
    grep -q '^cnt|' "$f" || ok "[$st] gha_logs: no error-class matches in last ${DBLOGS_HOURS}h"
    ok "[$st] gha_logs error-class scan done (window ${DBLOGS_HOURS}h)"
    # devstats DB gha_computed flags/locks ages
    f2="$TMPD/dblogs-computed-$st.txt"
    {
      echo "psql -U $PG_USER -d devstats -tA -F'|' <<'SQL'"
      echo "select metric, extract(epoch from now() - dt)::bigint from gha_computed order by metric;"
      echo "SQL"
    } | pg_script "$st" "$p" > "$f2" || true
    while IFS='|' read -r metric agesec; do
      [ -z "$metric" ] && continue
      ah=$(( ${agesec:-0} / 3600 ))
      case "$metric" in
        giant_lock) [ "$ah" -ge 12 ] && warn "[$st] devstats.gha_computed: giant_lock present for $(hfmt $ah) (stuck?)" || note "[$st] devstats.gha_computed: giant_lock present ($(hfmt $ah) old)";;
        devstats_running) note "[$st] devstats.gha_computed: devstats_running flag present ($(hfmt $ah) old)";;
        *) ok "[$st] devstats.gha_computed: $metric ($(hfmt $ah) old)";;
      esac
    done < "$f2"
    [ -s "$f2" ] || ok "[$st] devstats.gha_computed: no flags/locks present"
    # devstats DB gha_locks (owned locks; flags-report covers orphan owners, here we check ages)
    f2b="$TMPD/dblogs-locks-$st.txt"
    {
      echo "psql -U $PG_USER -d devstats -tA -F'|' <<'SQL'"
      echo "select name, owner, extract(epoch from now() - dt)::bigint from gha_locks order by dt;"
      echo "SQL"
    } | pg_script "$st" "$p" > "$f2b" || true
    if [ -s "$f2b" ]; then
      while IFS='|' read -r lname lowner lagesec; do
        [ -z "$lname" ] && continue
        lh=$(( ${lagesec:-0} / 3600 ))
        [ "$lh" -ge 12 ] && warn "[$st] devstats.gha_locks: lock '$lname' owned by '$lowner' held $(hfmt $lh) (stuck?)" || note "[$st] devstats.gha_locks: lock '$lname' owned by '$lowner' ($(hfmt $lh) old)"
      done < "$f2b"
    else
      ok "[$st] devstats.gha_locks: no lock rows"
    fi
    # shared affiliations import freshness (gha_logs prog=import_affs)
    f3="$TMPD/dblogs-impaffs-$st.txt"
    {
      echo "psql -U $PG_USER -d devstats -tA -F'|' <<'SQL'"
      echo "select coalesce(extract(epoch from now() - max(dt))::bigint, -1),"
      echo "       count(*) filter (where msg ilike '%error%' and msg not ilike '%0 errors%' and dt > now() - interval '${DBLOGS_HOURS} hours')"
      echo "from gha_logs where prog = 'import_affs';"
      echo "SQL"
    } | pg_script "$st" "$p" > "$f3" || true
    IFS='|' read -r impage imperrs < "$f3" || true
    if [ "${impage:--1}" = "-1" ]; then
      note "[$st] no import_affs activity in gha_logs at all"
    else
      ih=$(( impage / 3600 ))
      [ "$ih" -gt "$IMPORT_AFFS_WARN" ] && warn "[$st] shared affiliations import: last gha_logs activity $(hfmt $ih) ago (> ${IMPORT_AFFS_WARN}h)" || ok "[$st] shared affiliations import active $(hfmt $ih) ago"
      [ "${imperrs:-0}" -gt 0 ] && warn "[$st] shared affiliations import: $imperrs error line(s) in last ${DBLOGS_HOURS}h" || ok "[$st] shared affiliations import: no errors in last ${DBLOGS_HOURS}h"
    fi
    # affiliations DB deep sanity: all 12 tables + referential/temporal/duplicate checks
    f4="$TMPD/dblogs-affdb-$st.txt"
    {
      echo "psql -U $PG_USER -d affiliations -tA -F'|' <<'SQL' 2>/dev/null"
      echo "select 'core:gha_actors', count(*) from gha_actors"
      echo "union all select 'core:gha_actors_affiliations', count(*) from gha_actors_affiliations"
      echo "union all select 'core:gha_actors_emails', count(*) from gha_actors_emails"
      echo "union all select 'core:gha_actors_names', count(*) from gha_actors_names"
      echo "union all select 'core:gha_companies', count(*) from gha_companies"
      echo "union all select 'core:gha_countries', count(*) from gha_countries"
      echo "union all select 'core:gha_imported_shas', count(*) from gha_imported_shas"
      echo "union all select 'aux:gha_bot_logins', count(*) from gha_bot_logins"
      echo "union all select 'aux:gha_map_actor_email', count(*) from gha_map_actor_email"
      echo "union all select 'aux:gha_map_id_to_login', count(*) from gha_map_id_to_login"
      echo "union all select 'aux:gha_map_login_to_id', count(*) from gha_map_login_to_id"
      echo "union all select 'aux:gha_map_name_to_login', count(*) from gha_map_name_to_login;"
      echo "select 'chk:dup_affs', count(*) from (select actor_id, company_name, dt_from, count(*) from gha_actors_affiliations group by 1,2,3 having count(*) > 1) x;"
      echo "select 'chk:null_company', count(*) from gha_actors_affiliations where company_name is null or company_name = '';"
      echo "select 'chk:bad_date_range', count(*) from gha_actors_affiliations where dt_from >= dt_to;"
      echo "select 'chk:dangling_affs', count(*) from gha_actors_affiliations a where not exists (select 1 from gha_actors t where t.id = a.actor_id);"
      echo "select 'chk:dangling_emails', count(*) from gha_actors_emails e where not exists (select 1 from gha_actors t where t.id = e.actor_id);"
      echo "select 'chk:dangling_names', count(*) from gha_actors_names n where not exists (select 1 from gha_actors t where t.id = n.actor_id);"
      echo "select 'chk:empty_login_actors', count(*) from gha_actors where login is null or login = '';"
      echo "SQL"
    } | pg_script "$st" "$p" > "$f4" || true
    if ! grep -q '|' "$f4"; then
      note "[$st] affiliations DB not present/accessible - skipped"
    else
      while IFS='|' read -r tbl cntv; do
        [ -z "$tbl" ] && continue
        case "$tbl" in
          chk:dup_affs)           [ "${cntv:-0}" -gt 0 ] && warn "[$st] affiliations DB: $cntv duplicated (actor,company,dt_from) affiliation row(s)" || ok "[$st] affiliations DB: no duplicated affiliation rows";;
          chk:null_company)       [ "${cntv:-0}" -gt 0 ] && warn "[$st] affiliations DB: $cntv affiliation row(s) with NULL/empty company" || ok "[$st] affiliations DB: no NULL/empty company affiliations";;
          chk:bad_date_range)     [ "${cntv:-0}" -gt 0 ] && warn "[$st] affiliations DB: $cntv affiliation row(s) with dt_from >= dt_to" || ok "[$st] affiliations DB: all affiliation date ranges sane";;
          chk:dangling_affs)      [ "${cntv:-0}" -gt 0 ] && warn "[$st] affiliations DB: $cntv affiliation row(s) referencing missing actor" || ok "[$st] affiliations DB: no dangling affiliations";;
          chk:dangling_emails)    [ "${cntv:-0}" -gt 0 ] && warn "[$st] affiliations DB: $cntv email row(s) referencing missing actor" || ok "[$st] affiliations DB: no dangling emails";;
          chk:dangling_names)     [ "${cntv:-0}" -gt 0 ] && warn "[$st] affiliations DB: $cntv name row(s) referencing missing actor" || ok "[$st] affiliations DB: no dangling names";;
          chk:empty_login_actors) [ "${cntv:-0}" -gt 0 ] && note "[$st] affiliations DB: $cntv actor(s) with NULL/empty login" || ok "[$st] affiliations DB: no empty-login actors";;
          core:*)                 [ "${cntv:-0}" -eq 0 ] && crit "[$st] affiliations DB: core table ${tbl#core:} is EMPTY" || ok "[$st] affiliations DB: ${tbl#core:} rows: $cntv";;
          aux:*)                  [ "${cntv:-0}" -eq 0 ] && warn "[$st] affiliations DB: aux table ${tbl#aux:} is empty" || ok "[$st] affiliations DB: ${tbl#aux:} rows: $cntv";;
        esac
      done < "$f4"
    fi
  done
fi

# ----------------------------------------------------------------------------------------------------- patroni -----
if run_section patroni; then
  section patroni "patroni cluster, replication, slots, WAL, connections, long queries"
  for st in $STAGES; do
    p="${PRIMARY[$st]:-$(primary_pod "$st")}"
    [ -z "$p" ] && { crit "[$st] no primary pod"; continue; }
    kc "$st" exec -c "$PG_CONTAINER" "$p" -- patronictl list > "$TMPD/patroni-$st.txt" 2>/dev/null </dev/null
    if [ ! -s "$TMPD/patroni-$st.txt" ]; then
      crit "[$st] patronictl list returned nothing"
    else
      leaders="$(awk -F'|' '/\|/ && $4 ~ /Leader/ {c++} END{print c+0}' "$TMPD/patroni-$st.txt")"
      [ "$leaders" = "1" ] && ok "[$st] exactly one patroni Leader" || crit "[$st] patroni Leader count = $leaders"
      while IFS='|' read -r _ member host role state tl rlsn rlag alsn alag _; do
        member="$(echo "$member" | tr -d ' ')"; role="$(echo "$role" | tr -d ' ')"; state="$(echo "$state" | tr -d ' ')"
        [ -z "$member" ] && continue
        case "$state" in
          running|streaming) ok "[$st] member $member $role/$state";;
          *) crit "[$st] patroni member $member state=$state (role=$role)";;
        esac
        lagv="$(echo "${alag:-}" | tr -d ' ')"
        case "$lagv" in
          ''|Lag|*[!0-9]*) ;;
          *) [ "$lagv" -ge "$LAG_WARN_MB" ] && warn "[$st] member $member replay lag ${lagv}MB";;
        esac
      done < <(grep '^|' "$TMPD/patroni-$st.txt" | grep -v Member)
      tls="$(grep '^|' "$TMPD/patroni-$st.txt" | grep -v Member | awk -F'|' '{gsub(/ /,"",$6); if ($6 != "") print $6}' | sort -u | wc -l | tr -d ' ')"
      [ "$tls" = "1" ] && ok "[$st] single timeline across members" || warn "[$st] multiple patroni timelines: $tls"
    fi
    # PG internals (read-only, single in-pod pass)
    {
      echo "psql -U $PG_USER -d postgres -tA <<'SQL'"
      echo "select 'repl|'||coalesce(client_addr::text,'?')||'|'||state||'|'||coalesce(sync_state,'')||'|'||coalesce(pg_wal_lsn_diff(pg_current_wal_lsn(),replay_lsn)::bigint,0) from pg_stat_replication;"
      echo "select 'slot|'||slot_name||'|'||active::text||'|'||coalesce(pg_wal_lsn_diff(pg_current_wal_lsn(),restart_lsn)::bigint,0) from pg_replication_slots;"
      echo "select 'wal|'||count(*)||'|'||coalesce(sum(size),0) from pg_ls_waldir() where name ~ '^[0-9A-F]{24}\$';"
      echo "select 'conn|'||count(*)||'|'||current_setting('max_connections') from pg_stat_activity;"
      echo "select 'long|'||count(*) from pg_stat_activity where state='active' and now()-query_start > interval '2 hours' and query not ilike 'autovacuum:%';"
      echo "select 'autovac|'||count(*) from pg_stat_activity where query ilike 'autovacuum:%';"
      echo "select 'uptime|'||extract(epoch from now()-pg_postmaster_start_time())::bigint;"
      echo "SQL"
    } | pg_script "$st" "$p" > "$TMPD/pg-$st.txt"
    while IFS='|' read -r tag a b c d; do
      case "$tag" in
        repl)
          mb=$(( ${d:-0} / 1048576 ))
          if [ "$b" = "streaming" ]; then
            [ "$mb" -ge "$LAG_WARN_MB" ] && warn "[$st] replication to $a lag ${mb}MB" || ok "[$st] replication to $a streaming (lag ${mb}MB, ${c:-async})"
          else warn "[$st] replication to $a state=$b"; fi;;
        slot)
          mb=$(( ${c:-0} / 1048576 ))
          if [ "$b" = "t" ] || [ "$b" = "true" ]; then
            [ "$mb" -ge $((LAG_WARN_MB*4)) ] && warn "[$st] slot $a retains ${mb}MB WAL" || ok "[$st] slot $a active (retained ${mb}MB)"
          else warn "[$st] replication slot $a INACTIVE (retains ${mb}MB WAL)"; fi;;
        wal)
          gb=$(( ${b:-0} / 1073741824 ))
          [ "$gb" -ge "$WAL_WARN_GB" ] && warn "[$st] pg_wal: $a segments, ${gb}GB (>= ${WAL_WARN_GB}GB)" || ok "[$st] pg_wal: $a segments, ${gb}GB";;
        conn)
          pct=$(( ${a:-0} * 100 / ${b:-1} ))
          [ "$pct" -ge "$CONN_WARN_PCT" ] && warn "[$st] connections $a/$b (${pct}%)" || ok "[$st] connections $a/$b (${pct}%)";;
        long)
          [ "${a:-0}" -gt 0 ] && note "[$st] $a active queries running > 2h" || ok "[$st] no queries > 2h";;
        autovac) ok "[$st] autovacuum workers: ${a:-0}";;
        uptime) ok "[$st] postgres uptime $(hfmt $(( ${a:-0} / 3600 )))";;
      esac
    done < "$TMPD/pg-$st.txt"
  done
fi

# ----------------------------------------------------------------------------------------------------- storage -----
declare -A PV_BY_NODE=()
if run_section storage; then
  section storage "PV/PVC health, placements per node, capacities, openebs"
  kubectl get pv -o json > "$TMPD/pvs.json" 2>/dev/null
  npv="$(jq '.items|length' "$TMPD/pvs.json")"
  ok "$npv PVs total"
  while IFS='|' read -r name phase; do
    [ -z "$name" ] && continue
    [ "$phase" = "Bound" ] || warn "PV $name phase=$phase"
  done < <(jq -r '.items[] | "\(.metadata.name)|\(.status.phase)"' "$TMPD/pvs.json")
  while read -r cnt node; do
    [ -z "${node:-}" ] && continue
    sz="$(jq -r --arg n "$node" '[.items[] | select((.spec.nodeAffinity.required.nodeSelectorTerms[0].matchExpressions[0].values[0] // "") == $n) | .spec.capacity.storage] | join(",")' "$TMPD/pvs.json" | head -c 200)"
    ok "node $node hosts $cnt local PVs"
    PV_BY_NODE[$node]="$cnt"
  done < <(jq -r '.items[] | .spec.nodeAffinity.required.nodeSelectorTerms[0].matchExpressions[0].values[0] // empty' "$TMPD/pvs.json" | sort | uniq -c | awk '{print $1" "$2}')
  # openebs control plane
  oebs_bad="$(kubectl -n openebs get pods --no-headers 2>/dev/null | grep -cv ' Running ' || true)"
  if [ "${oebs_bad:-0}" -gt 0 ]; then warn "openebs namespace has $oebs_bad non-Running pods"; else ok "openebs control plane pods Running"; fi
fi

# ------------------------------------------------------------------------------------------------------ clones -----
if run_section clones; then
  section clones "git clones presence in every project repos PVC (batch ssh per node)"
  if [ ! -f projects.yaml ]; then
    warn "projects.yaml missing - cannot map projects to main repos; skipping"
  else
    # proj -> main_repo map (prod file; test-only projects picked from docker-images copy when present)
    awk '/^  [a-z0-9_-]+:$/{gsub(/[: ]/,""); p=$0} /^    main_repo: /{gsub(/'"'"'/,""); print p"|"$2}' projects.yaml > "$TMPD/mainrepos.txt"
    [ -f ../devstats-docker-images/devstats-helm/projects.yaml ] && \
      awk '/^  [a-z0-9_-]+:$/{gsub(/[: ]/,""); p=$0} /^    main_repo: /{gsub(/'"'"'/,""); print p"|"$2}' ../devstats-docker-images/devstats-helm/projects.yaml >> "$TMPD/mainrepos.txt"
    kubectl get pv -o json > "$TMPD/pvs.json" 2>/dev/null
    for st in $STAGES; do
      kc "$st" get pvc -o json > "$TMPD/pvc-$st.json" 2>/dev/null
      : > "$TMPD/clonechk-$st.txt"   # node|path|proj|main_repo
      while IFS='|' read -r pvc vol; do
        case "$pvc" in devstats-pvc-*) proj="${pvc#devstats-pvc-}";; *) continue;; esac
        line="$(jq -r --arg v "$vol" '.items[] | select(.metadata.name==$v) | "\(.spec.local.path // .spec.hostPath.path // "")|\(.spec.nodeAffinity.required.nodeSelectorTerms[0].matchExpressions[0].values[0] // "")"' "$TMPD/pvs.json")"
        path="${line%%|*}"; node="${line##*|}"
        [ -z "$path" ] || [ -z "$node" ] && { note "[$st] PVC $pvc: cannot resolve PV path/node"; continue; }
        mr="$(awk -F'|' -v p="$proj" '$1==p{print $2; exit}' "$TMPD/mainrepos.txt")"
        echo "$node|$path|$proj|${mr:-}" >> "$TMPD/clonechk-$st.txt"
      done < <(jq -r '.items[] | "\(.metadata.name)|\(.spec.volumeName)"' "$TMPD/pvc-$st.json")
      nch="$(wc -l < "$TMPD/clonechk-$st.txt" | tr -d ' ')"
      ok "[$st] checking clones on $nch project PVCs"
      for node in $NODES_LIST; do
        grep "^$node|" "$TMPD/clonechk-$st.txt" > "$TMPD/clonechk-$st-$node.txt" 2>/dev/null || continue
        [ -s "$TMPD/clonechk-$st-$node.txt" ] || continue
        {
          echo 'while IFS="|" read -r node path proj mr; do'
          echo '  d="$path/devstats_repos"'
          echo '  if [ ! -d "$d" ]; then echo "$proj|nodir"; continue; fi'
          echo '  n=$(find "$d" -mindepth 2 -maxdepth 2 -type d 2>/dev/null | head -50 | wc -l)'
          echo '  if [ -n "$mr" ] && [ "$mr" != "" ]; then'
          echo '    if [ -d "$d/$mr/.git" ] || [ -f "$d/$mr/HEAD" ]; then echo "$proj|ok|$n"; else echo "$proj|nomain|$mr|$n"; fi'
          echo '  else'
          echo '    if [ "$n" -gt 0 ]; then echo "$proj|ok|$n"; else echo "$proj|empty"; fi'
          echo '  fi'
          echo 'done <<EOF_LIST'
          cat "$TMPD/clonechk-$st-$node.txt"
          echo 'EOF_LIST'
        } | ssh $SSH_OPTS "$SSH_USER@$node" bash -s > "$TMPD/cloneout-$st-$node.txt" 2>/dev/null
        while IFS='|' read -r proj status extra extra2; do
          case "$status" in
            ok) ok "[$st] $proj clones present on $node (${extra:-?} org dirs sampled)";;
            nomain) warn "[$st] $proj: main repo clone MISSING ($extra) in PVC on $node";;
            nodir) warn "[$st] $proj: devstats_repos dir missing in PVC on $node";;
            empty) warn "[$st] $proj: devstats_repos EMPTY on $node";;
            *) note "[$st] $proj: unparsable clone check result";;
          esac
        done < "$TMPD/cloneout-$st-$node.txt"
      done
    done
  fi
fi

# ----------------------------------------------------------------------------------------------------- nodesys -----
if run_section nodesys; then
  section nodesys "per-node: disks, inodes, memory, PSI, OOM, units, NTP, clock, bandwidth, btrfs, recompress"
  NODESYS_START="$(date +%s)"
  for node in $NODES_LIST; do
    (
      ssh $SSH_OPTS "$SSH_USER@$node" bash -s <<'REMOTE' > "$TMPD/node-$node.txt" 2>/dev/null
echo "reach|ok"
echo "epoch|$(date +%s)"
for m in / /data; do
  [ -d "$m" ] || continue
  df -P "$m" 2>/dev/null | awk -v m="$m" 'NR==2{gsub(/%/,"",$5); print "df|"m"|"$5"|"$2"|"$4}'
  df -Pi "$m" 2>/dev/null | awk -v m="$m" 'NR==2{gsub(/%/,"",$5); print "di|"m"|"$5}'
done
free -m 2>/dev/null | awk '/^Mem:/{printf "mem|%d|%d\n", $2, $3}'
for f in cpu memory io; do
  [ -f /proc/pressure/$f ] && awk -v f=$f '/^some/{gsub(/avg60=/,"",$3); print "psi|"f"|"$3}' /proc/pressure/$f
done
dmesg -T 2>/dev/null | grep -iE 'out of memory|oom-kill' | tail -2 | sed 's/^/oom|/'
echo "failed|$(systemctl --failed --no-legend 2>/dev/null | grep -c . || echo 0)"
echo "ntp|$(timedatectl show -p NTPSynchronized --value 2>/dev/null || echo unknown)"
echo "load|$(cut -d' ' -f1-3 /proc/loadavg 2>/dev/null)"
echo "cores|$(nproc 2>/dev/null || echo 0)"
IF=$(ip route show default 2>/dev/null | awk '{print $5; exit}')
if [ -n "$IF" ]; then
  R1=$(awk -v i="$IF:" '$1==i{print $2" "$10}' /proc/net/dev)
  sleep 2
  R2=$(awk -v i="$IF:" '$1==i{print $2" "$10}' /proc/net/dev)
  echo "net|$IF|$R1|$R2"
fi
if [ -d /data ] && command -v btrfs >/dev/null 2>&1; then
  btrfs device stats /data 2>/dev/null | awk '$2 != 0 {print "btrfserr|"$1"|"$2}'
  echo "btrfsok|checked"
fi
if [ -f /var/log/btrfs-recompress.log ]; then
  echo "recomp_mtime|$(stat -c %Y /var/log/btrfs-recompress.log 2>/dev/null || echo 0)"
  # inspect only the LAST v4 run block (from last '=== START' to EOF)
  if grep -q '^=== START' /var/log/btrfs-recompress.log 2>/dev/null; then
    awk 'BEGIN{n=0} /^=== START/{n=NR} {l[NR]=$0} END{for(i=n;i<=NR;i++) print l[i]}' /var/log/btrfs-recompress.log 2>/dev/null \
      | grep -E 'rc=[1-9]' | tail -2 | sed 's/^/recomp_bad|/'
    echo "recomp_v4|yes"
  else
    echo "recomp_v4|no"
  fi
fi
[ -f /etc/cron.d/btrfs-recompress ] && echo "recomp_cron|present" || echo "recomp_cron|missing"
REMOTE
    ) &
  done
  wait
  for node in $NODES_LIST; do
    f="$TMPD/node-$node.txt"
    if ! grep -q '^reach|ok' "$f" 2>/dev/null; then crit "node $node UNREACHABLE via ssh"; continue; fi
    ok "node $node ssh reachable"
    while IFS='|' read -r tag a b c d; do
      case "$tag" in
        epoch)
          # node-vs-local clock offset is informational only (local host clock may drift) - VERBOSE/DEBUG only
          _now="$(date +%s)"
          if [ "$a" -lt $(( NODESYS_START - SKEW_WARN )) ] || [ "$a" -gt $(( _now + SKEW_WARN )) ]; then
            ok "node $node clock offset vs local host (node epoch $a vs local window $NODESYS_START..$_now)"
          else
            ok "node $node clock in sync"
          fi;;
        df)
          if [ "$b" -ge "$DF_CRIT" ]; then crit "node $node $a disk ${b}% used"
          elif [ "$b" -ge "$DF_WARN" ]; then warn "node $node $a disk ${b}% used"
          else ok "node $node $a disk ${b}% used"; fi;;
        di)
          [ "$b" -ge "$INODE_WARN" ] 2>/dev/null && warn "node $node $a inodes ${b}% used" || ok "node $node $a inodes ${b}%";;
        mem)
          pct=$(( ${b:-0} * 100 / ( ${a:-1} == 0 ? 1 : a ) ))
          [ "$pct" -ge "$MEM_WARN" ] && warn "node $node memory ${pct}% used (${b}/${a} MB)" || ok "node $node memory ${pct}% (${b}/${a} MB)";;
        psi)
          v="${b%%.*}"
          case "$a" in
            cpu) t=$PSI_CPU_WARN;; memory) t=$PSI_MEM_WARN;; io) t=$PSI_IO_WARN;; *) t=100;;
          esac
          [ "${v:-0}" -ge "$t" ] 2>/dev/null && warn "node $node PSI $a some/avg60=${b}" || ok "node $node PSI $a avg60=${b}";;
        oom) note "node $node OOM event in dmesg: $(echo "$a|$b|$c" | head -c 160)";;
        failed) [ "${a:-0}" -gt 0 ] && warn "node $node has $a failed systemd units" || ok "node $node no failed units";;
        ntp) [ "$a" = "yes" ] && ok "node $node NTP synchronized" || warn "node $node NTP not synchronized ($a)";;
        load) ok "node $node loadavg $a $b $c";;
        net)
          r1rx="$(echo "$b" | awk '{print $1}')"; r1tx="$(echo "$b" | awk '{print $2}')"
          r2rx="$(echo "$c" | awk '{print $1}')"; r2tx="$(echo "$c" | awk '{print $2}')"
          rx=$(( (r2rx - r1rx) / 2 / 1048576 )); tx=$(( (r2tx - r1tx) / 2 / 1048576 ))
          ok "node $node net($a) rx ${rx}MB/s tx ${tx}MB/s (2s sample)";;
        btrfserr) warn "node $node btrfs device error counter: $a = $b";;
        btrfsok) ok "node $node btrfs device error counters all zero";;
        recomp_mtime)
          agd=$(( (NOW_EPOCH - ${a:-0}) / 86400 ))
          [ "$agd" -gt "$RECOMPRESS_MAX_DAYS" ] && warn "node $node btrfs-recompress last activity ${agd}d ago (> ${RECOMPRESS_MAX_DAYS}d)" || ok "node $node btrfs-recompress log active ${agd}d ago";;
        recomp_bad) warn "node $node btrfs-recompress last run failure: $(echo "$a" | head -c 160)";;
        recomp_v4) [ "$a" = "yes" ] && ok "node $node recompress log has v4 run blocks" || note "node $node recompress: no v4 run yet (scheduled monthly; old-format log only)";;
        recomp_cron) [ "$a" = "present" ] && ok "node $node recompress cron present" || warn "node $node /etc/cron.d/btrfs-recompress MISSING";;
      esac
    done < "$f"
  done
fi

# --------------------------------------------------------------------------------------------------------- web -----
HOSTS_FILE="$TMPD/hosts.txt"
collect_hosts() {
  [ -s "$HOSTS_FILE" ] && return
  for st in $STAGES; do
    kca "$st" get ingress -A -o json 2>/dev/null | jq -r '.items[] | select(.metadata.name | startswith("cm-acme") | not) | .spec.rules[].host // empty | select(. != "" and . != "null")'
  done | sort -u > "$HOSTS_FILE"
}
if run_section web; then
  section web "HTTPS liveness of every ingress host (grafanas, statics, API, backups page)"
  collect_hosts
  nh="$(wc -l < "$HOSTS_FILE" | tr -d ' ')"
  ok "checking $nh hostnames (${PAR}x parallel, timeout ${HTTP_TIMEOUT}s)"
  xargs -n1 -P "$PAR" -I{} sh -c '
    out=$(curl -sk -o /dev/null -w "%{http_code}|%{time_total}" --max-time '"$HTTP_TIMEOUT"' "https://{}/" 2>/dev/null)
    echo "{}|$out"
  ' < "$HOSTS_FILE" > "$TMPD/webout.txt" 2>/dev/null
  # serial confirm pass for failures (parallel burst can rate-limit/starve conns -> false 000s)
  grep '|000|' "$TMPD/webout.txt" | cut -d'|' -f1 > "$TMPD/webfail.txt" || true
  if [ -s "$TMPD/webfail.txt" ]; then
    while read -r h; do
      sleep 1
      out=$(curl -sk -o /dev/null -w "%{http_code}|%{time_total}" --max-time "$HTTP_TIMEOUT" "https://$h/" 2>/dev/null)
      sed -i.bak "s#^$h|000|.*#$h|$out#" "$TMPD/webout.txt" 2>/dev/null || true
    done < "$TMPD/webfail.txt"
  fi
  while IFS='|' read -r h code t; do
    ts="${t%%.*}"
    case "$code" in
      200|301|302|303|307|308|401) 
        [ "${ts:-0}" -ge 10 ] && note "https://$h slow: ${t}s (HTTP $code)" || ok "https://$h HTTP $code (${t}s)";;
      000) if archived_host "$h"; then ok "https://$h unreachable (archived project - no instance expected)"; elif known_down "$h"; then note "https://$h unreachable (KNOWN_DOWN_HOSTS_RE match)"; else crit "https://$h UNREACHABLE (timeout/conn failure)"; fi;;
      *) if archived_host "$h"; then ok "https://$h HTTP $code (archived project - no instance expected)"; elif known_down "$h"; then note "https://$h HTTP $code (KNOWN_DOWN_HOSTS_RE match)"; else warn "https://$h HTTP $code"; fi;;
    esac
  done < "$TMPD/webout.txt"
  # grafana deployments health per stage
  for st in $STAGES; do
    while IFS='|' read -r name des avail; do
      [ -z "$name" ] && continue
      [ "${avail:-0}" -lt "${des:-1}" ] && warn "[$st] deployment $name available $avail/$des" 
    done < <(kc "$st" get deploy -o json 2>/dev/null | jq -r '.items[] | "\(.metadata.name)|\(.spec.replicas)|\(.status.availableReplicas // 0)"')
    ndep="$(kc "$st" get deploy --no-headers 2>/dev/null | wc -l | tr -d ' ')"
    ok "[$st] $ndep deployments checked for availability"
  done
  # DevStats API deep check
  api_out="$(curl -sk --max-time "$HTTP_TIMEOUT" -XPOST -H 'Content-Type: application/json' -d '{"api":"Health","payload":{"project":"all"}}' https://devstats.cncf.io/api/v1 2>/dev/null)"
  if grep -q '"events":[0-9]' <<<"$api_out"; then ok "DevStats API Health: $api_out"; else warn "DevStats API Health endpoint bad response: $(echo "$api_out" | head -c 160)"; fi
fi

# ----------------------------------------------------------------------------------------------------- backups -----
if run_section backups; then
  section backups "backups CJ, nginx backups page presence + per-DB dump freshness"
  collect_cj prod
  line="$(grep '^devstats-backups|' "$TMPD/cjsched-prod.txt" || true)"
  if [ -n "$line" ]; then
    lastok="$(echo "$line" | cut -d'|' -f5)"
    created="$(echo "$line" | cut -d'|' -f6)"
    if [ -n "$lastok" ]; then
      a=$(age_h "$(iso2epoch "$lastok")")
      [ "$a" -gt $((BACKUP_WARN_DAYS*24)) ] && warn "backups CJ last success $(hfmt $a) ago" || ok "backups CJ last success $(hfmt $a) ago (schedule $(echo "$line" | cut -d'|' -f2))"
    elif [ "$(age_h "$(iso2epoch "$created")")" -gt $((BACKUP_WARN_DAYS*24)) ]; then
      warn "backups CJ never succeeded although $(hfmt $(age_h "$(iso2epoch "$created")")) old"
    else
      ok "backups CJ not due yet (young CJ; page freshness checked below)"
    fi
  else
    warn "devstats-backups CronJob not found"
  fi
  page="$(curl -sk --max-time 30 "https://devstats.cncf.io/backups/" 2>/dev/null)"
  # transient-guard: up to 3 retries with backoff (ingress may be busy right after web section burst)
  for _try in 1 2 3; do
    grep -q 'Index of /backups/' <<<"$page" && break
    sleep $((_try*5)); page="$(curl -sk --max-time 30 "https://devstats.cncf.io/backups/" 2>/dev/null)"
  done
  if ! grep -q 'Index of /backups/' <<<"$page"; then
    crit "backups page https://devstats.cncf.io/backups/ not serving an index"
  else
    ok "backups page serving nginx index"
    # normalize: one <a ...> entry per line (page may be served as a single line)
    echo "$page" | sed 's/<a /\
<a /g' | awk -F'"' '/^<a href=".*\.(dump|tar\.xz)"/{split($0,a,"</a>"); n=$2; rest=a[2]; gsub(/^ +/,"",rest); split(rest,b," "); print n"|"b[1]" "b[2]"|"b[3]}' > "$TMPD/backups.txt"
    ndumps="$(wc -l < "$TMPD/backups.txt" | tr -d ' ')"
    [ "$ndumps" = "0" ] && crit "backups page lists no dump/tar.xz files" || ok "backups page lists $ndumps backup files"
    stale=0
    while IFS='|' read -r fn dt sz; do
      ep="$(ngx2epoch "$dt")"
      [ "$ep" = "0" ] && { note "backup $fn: unparsable date '$dt'"; continue; }
      ad=$(( (NOW_EPOCH - ep) / 86400 ))
      if [ "$ad" -gt "$BACKUP_WARN_DAYS" ]; then stale=$((stale+1)); warn "backup $fn is ${ad}d old (> ${BACKUP_WARN_DAYS}d)"; else ok "backup $fn ${ad}d old ($sz bytes)"; fi
    done < "$TMPD/backups.txt"
    # DBs missing a dump entirely
    if [ -f devel/all_prod_dbs.txt ]; then
      miss=0
      while read -r db; do
        [ -z "$db" ] && continue
        case "$db" in devstats) continue;; esac
        archived_db "$db" && { note "archived project DB $db skipped in backups check"; continue; }
        grep -qE "^$db\.(dump|tar\.xz)\|" "$TMPD/backups.txt" || { miss=$((miss+1)); warn "no backup (dump/tar.xz) found for DB $db"; }
      done < <(tr ' \t' '\n' < devel/all_prod_dbs.txt | sed '/^$/d')
      [ "$miss" = "0" ] && ok "every DB from devel/all_prod_dbs.txt has a backup on the backups page"
    fi
    grep -q 'href="grafana' <<<"$page" && ok "grafana/ backups subdir present" || warn "grafana/ backups subdir missing on backups page"
  fi
fi

# ------------------------------------------------------------------------------------------------------- certs -----
if run_section certs; then
  section certs "TLS secret expiries, live endpoint certs, stuck ACME challenges"
  kubectl get secret -A --field-selector type=kubernetes.io/tls -o json > "$TMPD/tls.json" 2>/dev/null
  nsec="$(jq '.items|length' "$TMPD/tls.json")"
  ok "$nsec TLS secrets found"
  while IFS='|' read -r ns name crt; do
    [ -z "$crt" ] && continue
    end="$(echo "$crt" | openssl base64 -d -A 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)"
    if echo "$crt" | openssl base64 -d -A 2>/dev/null | openssl x509 -noout -checkend $((CERT_CRIT_DAYS*86400)) >/dev/null 2>&1; then
      if echo "$crt" | openssl base64 -d -A 2>/dev/null | openssl x509 -noout -checkend $((CERT_WARN_DAYS*86400)) >/dev/null 2>&1; then
        ok "tls secret $ns/$name valid past ${CERT_WARN_DAYS}d (until $end)"
      else
        warn "tls secret $ns/$name expires within ${CERT_WARN_DAYS}d: $end"
      fi
    else
      crit "tls secret $ns/$name expires within ${CERT_CRIT_DAYS}d: $end"
    fi
  done < <(jq -r '.items[] | "\(.metadata.namespace)|\(.metadata.name)|\(.data["tls.crt"] // "")"' "$TMPD/tls.json")
  # live endpoint certs for apex hosts
  for h in devstats.cncf.io teststats.cncf.io devstats.cd.foundation devstats.graphql.org; do
    end="$(echo | openssl s_client -servername "$h" -connect "$h:443" 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)"
    if [ -z "$end" ]; then warn "cannot read live TLS cert of $h"; continue; fi
    if echo | openssl s_client -servername "$h" -connect "$h:443" 2>/dev/null | openssl x509 -noout -checkend $((CERT_WARN_DAYS*86400)) >/dev/null 2>&1; then
      ok "live cert $h valid past ${CERT_WARN_DAYS}d ($end)"
    else
      warn "live cert $h expires within ${CERT_WARN_DAYS}d: $end"
    fi
  done
  # stuck ACME solver ingresses (should exist only minutes during renewal)
  while IFS='|' read -r ns name created host; do
    [ -z "$name" ] && continue
    a=$(age_h "$(iso2epoch "$created")")
    if [ "$a" -ge 2 ]; then
      if archived_host "$host"; then ok "stuck ACME challenge for archived-project host $host ($(hfmt $a) old)"; elif known_down "$host"; then note "stuck ACME challenge for host $host ($(hfmt $a) old, KNOWN_DOWN_HOSTS_RE match)"; else warn "stuck ACME challenge: ingress $ns/$name for $host ($(hfmt $a) old) - cert order not completing"; fi
    else
      note "active ACME challenge for $host"
    fi
  done < <(kubectl get ingress -A -o json | jq -r '.items[] | select(.metadata.name | startswith("cm-acme")) | "\(.metadata.namespace)|\(.metadata.name)|\(.metadata.creationTimestamp)|\(.spec.rules[0].host)"')
  # cert-manager pods
  cmbad="$(kubectl -n cert-manager get pods --no-headers 2>/dev/null | grep -cv ' Running ' || true)"
  [ "${cmbad:-0}" -gt 0 ] && warn "cert-manager has $cmbad non-Running pods" || ok "cert-manager pods Running"
fi

# --------------------------------------------------------------------------------------------------------- dns -----
if run_section dns; then
  section dns "resolution of every ingress host + per-domain-family IP invariants"
  collect_hosts
  # family apex IPs
  declare -A APEX=()
  for fam in devstats.cncf.io teststats.cncf.io devstats.cd.foundation devstats.graphql.org; do
    ip="$(resolve_a "$fam")"
    if [ -n "$ip" ]; then APEX[$fam]="$ip"; ok "apex $fam -> $ip"; elif known_down "$fam"; then note "apex $fam does not resolve (KNOWN_DOWN_HOSTS_RE match)"; else crit "apex $fam does not resolve"; fi
  done
  export -f resolve_a
  xargs -n1 -P "$PAR" -I{} bash -c 'echo "{}|$(resolve_a "{}")"' < "$HOSTS_FILE" > "$TMPD/dnsout.txt" 2>/dev/null
  while IFS='|' read -r h ip; do
    if [ -z "$ip" ]; then if archived_host "$h"; then ok "host $h does not resolve (archived project)"; elif known_down "$h"; then note "host $h does not resolve (KNOWN_DOWN_HOSTS_RE match)"; else crit "host $h does NOT resolve"; fi; continue; fi
    fam=""
    case "$h" in
      *teststats.cncf.io) fam=teststats.cncf.io;;
      *devstats.cncf.io|devstats.cncf.io) fam=devstats.cncf.io;;
      *devstats.cd.foundation) fam=devstats.cd.foundation;;
      *devstats.graphql.org) fam=devstats.graphql.org;;
    esac
    if [ -n "$fam" ] && [ -n "${APEX[$fam]:-}" ]; then
      if [ "$ip" = "${APEX[$fam]}" ]; then ok "$h -> $ip (matches $fam)"; else warn "$h -> $ip differs from $fam apex ${APEX[$fam]}"; fi
    else
      ok "$h -> $ip"
    fi
  done < "$TMPD/dnsout.txt"
fi

# ----------------------------------------------------------------------------------------------------- summary -----
echo
echo "${c_blu}================================= SUMMARY =================================${c_off}"
echo "probes OK: $N_OK   notices: $N_NOTE   warnings: $N_WARN   criticals: $N_CRIT"
if [ "${#ISSUES[@]}" -gt 0 ]; then
  echo
  echo "All detected issues:"
  for i in "${ISSUES[@]}"; do echo "  $i"; done
fi
echo
if [ "$N_CRIT" -gt 0 ]; then echo "${c_red}VERDICT: CRITICAL issues present${c_off}"; exit 3
elif [ "$N_WARN" -gt 0 ]; then echo "${c_yel}VERDICT: warnings present${c_off}"; exit 2
elif [ "$N_NOTE" -gt 0 ]; then echo "${c_blu}VERDICT: healthy with notices${c_off}"; exit 1
else echo "${c_grn}VERDICT: fully healthy${c_off}"; exit 0
fi
