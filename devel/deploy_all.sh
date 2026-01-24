#!/bin/bash
# ARTWORK
# GET=1 (attempt to fetch Postgres database and Grafana database from the test server)
# AGET=1 (attempt to fetch 'All CNCF' Postgres database from the test server)
# INIT=1 (needs PG_PASS_RO, PG_PASS_TEAM, initialize from no postgres database state, creates postgres logs database and users)
# SKIPWWW=1 (skips Apache and SSL cert configuration, final result will be Grafana exposed on the server on its port (for example 3010) via HTTP)
# SKIPCERT=1 (skip certificate issue)
# SKIPVARS=1 (if set it will skip final Postgres vars regeneration)
# SKIPICONS=1 (if set it will skip updating all artworks)
# SKIPMAKE=1 (if set it will skip final make install call)
# CUSTGRAFPATH=1 (set this to use non-standard grafana instalation from ~/grafana.v5/)
# SETPASS=1 (should be set on a real first run to set main postgres password interactively, CANNOT be used without user interaction)
set -o pipefail
exec > >(tee run.log)
exec 2> >(tee errors.txt)
if [ -z "$PG_PASS" ]
then
  echo "$0: You need to set PG_PASS environment variable to run this script"
  exit 1
fi
if ( [ ! -z "$INIT" ] && ( [ -z "$PG_PASS_RO" ] || [ -z "$PG_PASS_TEAM" ] ) )
then
  echo "$0: You need to set PG_PASS_RO, PG_PASS_TEAM when using INIT"
  exit 1
fi

if [ ! -z "$CUSTGRAFPATH" ]
then
  GRAF_USRSHARE="$HOME/grafana.v5/usr.share.grafana"
  GRAF_VARLIB="$HOME/grafana.v5/var.lib.grafana"
  GRAF_ETC="$HOME/grafana.v5/etc.grafana"
fi

if [ -z "$GRAF_USRSHARE" ]
then
  GRAF_USRSHARE="/usr/share/grafana"
fi
if [ -z "$GRAF_VARLIB" ]
then
  GRAF_VARLIB="/var/lib/grafana"
fi
if [ -z "$GRAF_ETC" ]
then
  GRAF_ETC="/etc/grafana"
fi
export GRAF_USRSHARE
export GRAF_VARLIB
export GRAF_ETC

if [ ! -z "$ONLY" ]
then
  export ONLY
fi

host=`hostname`
function finish {
  sync_unlock.sh
  rm -f /tmp/deploy.wip 2>/dev/null
}
if [ -z "$TRAP" ]
then
  sync_lock.sh || exit -1
  trap finish EXIT
  export TRAP=1
  > /tmp/deploy.wip
fi

. ./devel/all_projs.sh || exit 2

if [ -z "$ONLYDB" ]
then
  host=`hostname`
  if [ $host = "teststats.cncf.io" ]
  then
    alldb=`cat ./devel/all_test_dbs.txt`
  else
    alldb=`cat ./devel/all_prod_dbs.txt`
  fi
else
  alldb=$ONLYDB
fi

LASTDB=""
for db in $alldb
do
  exists=`./devel/db.sh psql postgres -tAc "select 1 from pg_database where datname = '$db'"` || exit 100
  if [ ! "$exists" = "1" ]
  then
    LASTDB=$db
  fi
done
export LASTDB
echo "Last missing DB is $LASTDB"

if [ ! -z "$INIT" ]
then
  ./devel/init_database.sh || exit 1
fi

# OCI has no icon in cncf/artwork at all, so use "-" here
# Use GA="-" to skip GA (google analytics) code
# Use ICON="-" to skip project ICON
for proj in $all
do
  db=$proj
  if [ "$proj" = "kubernetes" ]
  then
         PROJ=kubernetes     PROJDB=gha            PROJREPO="kubernetes/kubernetes"           ORGNAME=Kubernetes        PORT=2999 ICON=kubernetes     GRAFSUFF=k8s            GA="-"  ./devel/deploy_proj.sh || exit 2
  elif [ "$proj" = "prometheus" ]
  then
         PROJ=prometheus     PROJDB=prometheus     PROJREPO="prometheus/prometheus"           ORGNAME=Prometheus        PORT=3001 ICON=prometheus     GRAFSUFF=prometheus     GA="-"  ./devel/deploy_proj.sh || exit 3
  elif [ "$proj" = "opentracing" ]
  then
         PROJ=opentracing    PROJDB=opentracing    PROJREPO="opentracing/opentracing-go"      ORGNAME=OpenTracing       PORT=3002 ICON=opentracing    GRAFSUFF=opentracing    GA="-"  ./devel/deploy_proj.sh || exit 4
  elif [ "$proj" = "fluentd" ]
  then
         PROJ=fluentd        PROJDB=fluentd        PROJREPO="fluent/fluentd"                  ORGNAME=Fluentd           PORT=3003 ICON=fluentd        GRAFSUFF=fluentd        GA="-"  ./devel/deploy_proj.sh || exit 5
  elif [ "$proj" = "linkerd" ]
  then
         PROJ=linkerd        PROJDB=linkerd        PROJREPO="linkerd/linkerd2"                ORGNAME=Linkerd           PORT=3004 ICON=linkerd        GRAFSUFF=linkerd        GA="-"  ./devel/deploy_proj.sh || exit 6
  elif [ "$proj" = "grpc" ]
  then
         PROJ=grpc           PROJDB=grpc           PROJREPO="grpc/grpc"                       ORGNAME=gRPC              PORT=3005 ICON=grpc           GRAFSUFF=grpc           GA="-"  ./devel/deploy_proj.sh || exit 7
  elif [ "$proj" = "coredns" ]
  then
         PROJ=coredns        PROJDB=coredns        PROJREPO="coredns/coredns"                 ORGNAME=CoreDNS           PORT=3006 ICON=coredns        GRAFSUFF=coredns        GA="-"  ./devel/deploy_proj.sh || exit 8
  elif [ "$proj" = "containerd" ]
  then
         PROJ=containerd     PROJDB=containerd     PROJREPO="containerd/containerd"           ORGNAME=containerd        PORT=3007 ICON=containerd     GRAFSUFF=containerd     GA="-" ./devel/deploy_proj.sh || exit 9
  elif [ "$proj" = "rkt" ]
  then
         PROJ=rkt            PROJDB=rkt            PROJREPO="rkt/rkt"                         ORGNAME=rkt               PORT=3008 ICON=rkt            GRAFSUFF=rkt            GA="-" ./devel/deploy_proj.sh || exit 10
  elif [ "$proj" = "cni" ]
  then
         PROJ=cni            PROJDB=cni            PROJREPO="containernetworking/cni"         ORGNAME=CNI               PORT=3009 ICON=cni            GRAFSUFF=cni            GA="-" ./devel/deploy_proj.sh || exit 11
  elif [ "$proj" = "envoy" ]
  then
         PROJ=envoy          PROJDB=envoy          PROJREPO="envoyproxy/envoy"                ORGNAME=Envoy             PORT=3010 ICON=envoy          GRAFSUFF=envoy          GA="-" ./devel/deploy_proj.sh || exit 12
  elif [ "$proj" = "jaeger" ]
  then
         PROJ=jaeger         PROJDB=jaeger         PROJREPO="jaegertracing/jaeger"            ORGNAME=Jaeger            PORT=3011 ICON=jaeger         GRAFSUFF=jaeger         GA="-" ./devel/deploy_proj.sh || exit 13
  elif [ "$proj" = "notary" ]
  then
         PROJ=notary         PROJDB=notary         PROJREPO="notaryproject/notation"          ORGNAME=Notary            PORT=3012 ICON=notary         GRAFSUFF=notary         GA="-" ./devel/deploy_proj.sh || exit 14
  elif [ "$proj" = "tuf" ]
  then
         PROJ=tuf            PROJDB=tuf            PROJREPO="theupdateframework/python-tuf"   ORGNAME=TUF               PORT=3013 ICON=tuf            GRAFSUFF=tuf            GA="-" ./devel/deploy_proj.sh || exit 15
  elif [ "$proj" = "rook" ]
  then
         PROJ=rook           PROJDB=rook           PROJREPO="rook/rook"                       ORGNAME=Rook              PORT=3014 ICON=rook           GRAFSUFF=rook           GA="-" ./devel/deploy_proj.sh || exit 16
  elif [ "$proj" = "vitess" ]
  then
         PROJ=vitess         PROJDB=vitess         PROJREPO="vitessio/vitess"                 ORGNAME=Vitess            PORT=3015 ICON=vitess         GRAFSUFF=vitess         GA="-" ./devel/deploy_proj.sh || exit 17
  elif [ "$proj" = "nats" ]
  then
         PROJ=nats           PROJDB=nats           PROJREPO="nats-io/nats-server"             ORGNAME=NATS              PORT=3016 ICON=nats           GRAFSUFF=nats           GA="-" ./devel/deploy_proj.sh || exit 18
  elif [ "$proj" = "opa" ]
  then
         PROJ=opa            PROJDB=opa            PROJREPO="open-policy-agent/opa"           ORGNAME=OPA               PORT=3017 ICON=opa            GRAFSUFF=opa            GA="-" ./devel/deploy_proj.sh || exit 19
  elif [ "$proj" = "spiffe" ]
  then
         PROJ=spiffe         PROJDB=spiffe         PROJREPO="spiffe/spiffe"                   ORGNAME=SPIFFE            PORT=3018 ICON=spiffe         GRAFSUFF=spiffe         GA="-" ./devel/deploy_proj.sh || exit 20
  elif [ "$proj" = "spire" ]
  then
         PROJ=spire          PROJDB=spire          PROJREPO="spiffe/spire"                    ORGNAME=SPIRE             PORT=3019 ICON=spire          GRAFSUFF=spire          GA="-" ./devel/deploy_proj.sh || exit 21
  elif [ "$proj" = "cloudevents" ]
  then
         PROJ=cloudevents    PROJDB=cloudevents    PROJREPO="cloudevents/spec"                ORGNAME=CloudEvents       PORT=3020 ICON=cloudevents    GRAFSUFF=cloudevents    GA="-" ./devel/deploy_proj.sh || exit 22
  elif [ "$proj" = "telepresence" ]
  then
         PROJ=telepresence   PROJDB=telepresence   PROJREPO="telepresenceio/telepresence"     ORGNAME=Telepresence      PORT=3021 ICON=telepresence   GRAFSUFF=telepresence   GA="-" ./devel/deploy_proj.sh || exit 23
  elif [ "$proj" = "helm" ]
  then
         PROJ=helm           PROJDB=helm           PROJREPO="helm/helm"                       ORGNAME=Helm              PORT=3022 ICON=helm           GRAFSUFF=helm           GA="-" ./devel/deploy_proj.sh || exit 24
  elif [ "$proj" = "openmetrics" ]
  then
         PROJ=openmetrics    PROJDB=openmetrics    PROJREPO="OpenObservability/OpenMetrics"   ORGNAME=OpenMetrics       PORT=3023 ICON=openmetrics    GRAFSUFF=openmetrics    GA="-" ./devel/deploy_proj.sh || exit 25
  elif [ "$proj" = "harbor" ]
  then
         PROJ=harbor         PROJDB=harbor         PROJREPO="goharbor/harbor"                 ORGNAME=Harbor            PORT=3024 ICON=harbor         GRAFSUFF=harbor         GA="-" ./devel/deploy_proj.sh || exit 26
  elif [ "$proj" = "etcd" ]
  then
         PROJ=etcd           PROJDB=etcd           PROJREPO="etcd-io/etcd"                    ORGNAME=etcd              PORT=3025 ICON=etcd           GRAFSUFF=etcd           GA="-" ./devel/deploy_proj.sh || exit 27
  elif [ "$proj" = "tikv" ]
  then
         PROJ=tikv           PROJDB=tikv           PROJREPO="tikv/tikv"                       ORGNAME=TiKV              PORT=3026 ICON=tikv           GRAFSUFF=tikv           GA="-" ./devel/deploy_proj.sh || exit 28
  elif [ "$proj" = "cortex" ]
  then
         PROJ=cortex         PROJDB=cortex         PROJREPO="cortexproject/cortex"            ORGNAME=Cortex            PORT=3027 ICON=cortex         GRAFSUFF=cortex         GA="-" ./devel/deploy_proj.sh || exit 29
  elif [ "$proj" = "buildpacks" ]
  then
         PROJ=buildpacks     PROJDB=buildpacks     PROJREPO="buildpacks/pack"                 ORGNAME=Buildpacks        PORT=3028 ICON=buildpacks     GRAFSUFF=buildpacks     GA="-" ./devel/deploy_proj.sh || exit 30
  elif [ "$proj" = "falco" ]
  then
         PROJ=falco          PROJDB=falco          PROJREPO="falcosecurity/falco"             ORGNAME=Falco             PORT=3029 ICON=falco          GRAFSUFF=falco          GA="-" ./devel/deploy_proj.sh || exit 31
  elif [ "$proj" = "dragonfly" ]
  then
         PROJ=dragonfly      PROJDB=dragonfly      PROJREPO="dragonflyoss/Dragonfly"          ORGNAME=Dragonfly         PORT=3030 ICON=dragonfly      GRAFSUFF=dragonfly       GA="-" ./devel/deploy_proj.sh || exit 39
  elif [ "$proj" = "virtualkubelet" ]
  then
    PROJ=virtualkubelet      PROJDB=virtualkubelet PROJREPO="virtual-kubelet/virtual-kubelet" ORGNAME="Virtual Kubelet" PORT=3031 ICON=virtualkubelet GRAFSUFF=virtualkubelet GA="-" ./devel/deploy_proj.sh || exit 40
  elif [ "$proj" = "kubeedge" ]
  then
    PROJ=kubeedge            PROJDB=kubeedge       PROJREPO="kubeedge/kubeedge"               ORGNAME=KubeEdge          PORT=3032 ICON=kubeedge       GRAFSUFF=kubeedge       GA="-" ./devel/deploy_proj.sh || exit 43
  elif [ "$proj" = "brigade" ]
  then
    PROJ=brigade             PROJDB=brigade        PROJREPO="brigadecore/brigade"             ORGNAME=Brigade           PORT=3033 ICON=brigade        GRAFSUFF=brigade        GA="-" ./devel/deploy_proj.sh || exit 44
  elif [ "$proj" = "crio" ]
  then
    PROJ=crio                PROJDB=crio           PROJREPO="cri-o/cri-o"                     ORGNAME="CRI-O"           PORT=3034 ICON=crio           GRAFSUFF=crio           GA="-" ./devel/deploy_proj.sh || exit 42
  elif [ "$proj" = "networkservicemesh" ]
  then
    PROJ=networkservicemesh  PROJDB=networkservicemesh PROJREPO="networkservicemesh/api"      ORGNAME="Network Service Mesh" PORT=3035 ICON=networkservicemesh GRAFSUFF=networkservicemesh GA="-" ./devel/deploy_proj.sh || exit 45
  elif [ "$proj" = "openebs" ]
  then
    PROJ=openebs             PROJDB=openebs        PROJREPO="openebs/openebs"                 ORGNAME=OpenEBS            PORT=3036 ICON=openebs        GRAFSUFF=openebs        GA="-" ./devel/deploy_proj.sh || exit 46
  elif [ "$proj" = "opentelemetry" ]
  then
    PROJ=opentelemetry       PROJDB=opentelemetry  PROJREPO="open-telemetry/opentelemetry-java" ORGNAME=OpenTelemetry   PORT=3037 ICON=opentelemetry  GRAFSUFF=opentelemetry  GA="-" ./devel/deploy_proj.sh || exit 49
  elif [ "$proj" = "thanos" ]
  then
    PROJ=thanos              PROJDB=thanos         PROJREPO="thanos-io/thanos"                ORGNAME=Thanos            PORT=3038 ICON=thanos         GRAFSUFF=thanos         GA="-" ./devel/deploy_proj.sh || exit 50
  elif [ "$proj" = "flux" ]
  then
    PROJ=flux                PROJDB=flux           PROJREPO="fluxcd/flux2"                    ORGNAME=Flux              PORT=3039 ICON=flux           GRAFSUFF=flux           GA="-" ./devel/deploy_proj.sh || exit 51
  elif [ "$proj" = "intoto" ]
  then
    PROJ=intoto              PROJDB=intoto         PROJREPO="in-toto/in-toto"                 ORGNAME="in-toto"         PORT=3040 ICON=intoto         GRAFSUFF=intoto         GA="-"  ./devel/deploy_proj.sh || exit 52
  elif [ "$proj" = "strimzi" ]
  then
    PROJ=strimzi             PROJDB=strimzi        PROJREPO="strimzi/strimzi-kafka-operator"  ORGNAME=Strimzi           PORT=3041 ICON=strimzi        GRAFSUFF=strimzi        GA="-"  ./devel/deploy_proj.sh || exit 53
  elif [ "$proj" = "kubevirt" ]
  then
    PROJ=kubevirt            PROJDB=kubevirt       PROJREPO="kubevirt/kubevirt"               ORGNAME=KubeVirt          PORT=3042 ICON=kubevirt       GRAFSUFF=kubevirt       GA="-"  ./devel/deploy_proj.sh || exit 60
  elif [ "$proj" = "longhorn" ]
  then
    PROJ=longhorn            PROJDB=longhorn       PROJREPO="longhorn/longhorn"               ORGNAME=Longhorn          PORT=3043 ICON=longhorn       GRAFSUFF=longhorn       GA="-"  ./devel/deploy_proj.sh || exit 61
  elif [ "$proj" = "chubaofs" ]
  then
    PROJ=chubaofs            PROJDB=chubaofs       PROJREPO="cubefs/cubefs"                   ORGNAME=CubeFS            PORT=3044 ICON=chubaofs       GRAFSUFF=chubaofs       GA="-"  ./devel/deploy_proj.sh || exit 62
  elif [ "$proj" = "keda" ]
  then
    PROJ=keda                PROJDB=keda           PROJREPO="kedacore/keda"                   ORGNAME=KEDA              PORT=3045 ICON=keda           GRAFSUFF=keda           GA="-"  ./devel/deploy_proj.sh || exit 63
  elif [ "$proj" = "smi" ]
  then
    PROJ=smi                 PROJDB=smi            PROJREPO="servicemeshinterface/smi-spec"   ORGNAME=SMI               PORT=3046 ICON=smi            GRAFSUFF=smi            GA="-"  ./devel/deploy_proj.sh || exit 64
  elif [ "$proj" = "argo" ]
  then
    PROJ=argo                PROJDB=argo           PROJREPO="argoproj/argo-cd"                ORGNAME=Argo              PORT=3047 ICON=argo           GRAFSUFF=argo           GA="-"  ./devel/deploy_proj.sh || exit 65
  elif [ "$proj" = "volcano" ]
  then
    PROJ=volcano             PROJDB=volcano        PROJREPO="volcano-sh/volcano"              ORGNAME=Volcano           PORT=3048 ICON=volcano        GRAFSUFF=volcano        GA="-"  ./devel/deploy_proj.sh || exit 66
  elif [ "$proj" = "cnigenie" ]
  then
    PROJ=cnigenie           PROJDB=cnigenie        PROJREPO="cni-genie/CNI-Genie"             ORGNAME="CNI-Genie"       PORT=3049 ICON=cnigenie       GRAFSUFF=cnigenie       GA="-" ./devel/deploy_proj.sh || exit 67
  elif [ "$proj" = "keptn" ]
  then
    PROJ=keptn              PROJDB=keptn           PROJREPO="keptn/keptn"                     ORGNAME=Keptn             PORT=3050 ICON=keptn          GRAFSUFF=keptn          GA="-" ./devel/deploy_proj.sh || exit 68
  elif [ "$proj" = "kudo" ]
  then
    PROJ=kudo               PROJDB=kudo            PROJREPO="kudobuilder/kudo"                ORGNAME=Kudo              PORT=3051 ICON=kudo           GRAFSUFF=kudo           GA="-" ./devel/deploy_proj.sh || exit 69
  elif [ "$proj" = "cloudcustodian" ]
  then
    PROJ=cloudcustodian     PROJDB=cloudcustodian  PROJREPO="cloud-custodian/cloud-custodian" ORGNAME="Cloud Custodian" PORT=3052 ICON=cloudcustodian GRAFSUFF=cloudcustodian GA="-" ./devel/deploy_proj.sh || exit 70
  elif [ "$proj" = "dex" ]
  then
    PROJ=dex                PROJDB=dex             PROJREPO="dexidp/dex"                      ORGNAME=Dex               PORT=3053 ICON=dex            GRAFSUFF= dex           GA="-" ./devel/deploy_proj.sh || exit 71
  elif [ "$proj" = "litmuschaos" ]
  then
    PROJ=litmuschaos        PROJDB=litmuschaos     PROJREPO="litmuschaos/litmus"              ORGNAME=LitmusChaos       PORT=3054 ICON=litmuschaos    GRAFSUFF=litmuschaos    GA="-" ./devel/deploy_proj.sh || exit 72
  elif [ "$proj" = "artifacthub" ]
  then
    PROJ=artifacthub        PROJDB=artifacthub     PROJREPO="artifacthub/hub"                 ORGNAME="Artifact Hub"    PORT=3055 ICON=artifacthub    GRAFSUFF=artifacthub    GA="-" ./devel/deploy_proj.sh || exit 73
  elif [ "$proj" = "kuma" ]
  then
    PROJ=kuma               PROJDB=kuma            PROJREPO="kumahq/kuma"                     ORGNAME=Kuma              PORT=3056 ICON=kuma           GRAFSUFF=kuma           GA="-" ./devel/deploy_proj.sh || exit 74
  elif [ "$proj" = "parsec" ]
  then
    PROJ=parsec             PROJDB=parsec          PROJREPO="parallaxsecond/parsec"           ORGNAME=PARSEC            PORT=3057 ICON=parsec         GRAFSUFF=parsec         GA="-" ./devel/deploy_proj.sh || exit 75
  elif [ "$proj" = "bfe" ]
  then
    PROJ=bfe                PROJDB=bfe             PROJREPO="bfenetworks/bfe"                 ORGNAME=BFE               PORT=3058 ICON=bfe            GRAFSUFF=bfe            GA="-" ./devel/deploy_proj.sh || exit 76
  elif [ "$proj" = "crossplane" ]
  then
    PROJ=crossplane         PROJDB=crossplane      PROJREPO="crossplane/crossplane"           ORGNAME=Crossplane        PORT=3059 ICON=crossplane     GRAFSUFF=crossplane     GA="-" ./devel/deploy_proj.sh || exit 77
  elif [ "$proj" = "contour" ]
  then
    PROJ=contour            PROJDB=contour         PROJREPO="projectcontour/contour"          ORGNAME=Contour           PORT=3060 ICON=contour        GRAFSUFF=contour        GA="-" ./devel/deploy_proj.sh || exit 78
  elif [ "$proj" = "operatorframework" ]
  then
    PROJ=operatorframework  PROJDB=operatorframework PROJREPO="operator-framework/operator-sdk" ORGNAME=Operator Framework PORT=3061 ICON=operatorframework GRAFSUFF=operatorframework GA="-" ./devel/deploy_proj.sh || exit 79
  elif [ "$proj" = "chaosmesh" ]
  then
    PROJ=chaosmesh          PROJDB=chaosmesh       PROJREPO="chaos-mesh/chaos-mesh"           ORGNAME="Chaos Mesh"      PORT=3062 ICON=chaosmesh      GRAFSUFF=chaosmesh      GA="-" ./devel/deploy_proj.sh || exit 80
  elif [ "$proj" = "serverlessworkflow" ]
  then
    PROJ=serverlessworkflow PROJDB=serverlessworkflow PROJREPO="serverlessworkflow/specification" ORGNAME="Serverless Workflow" PORT=3063 ICON=serverlessworkflow GRAFSUFF=serverlessworkflow GA="-" ./devel/deploy_proj.sh || exit 81
  elif [ "$proj" = "k3s" ]
  then
    PROJ=k3s                 PROJDB=k3s            PROJREPO="k3s-io/k3s"                      ORGNAME=K3s               PORT=3064 ICON=k3s            GRAFSUFF=k3s            GA="-" ./devel/deploy_proj.sh || exit 82
  elif [ "$proj" = "backstage" ]
  then
    PROJ=backstage           PROJDB=backstage      PROJREPO="backstage/backstag"              ORGNAME=Backstage         PORT=3065 ICON=backstage      GRAFSUFF=backstage      GA="-" ./devel/deploy_proj.sh || exit 83
  elif [ "$proj" = "tremor" ]
  then
    PROJ=tremor              PROJDB=tremor         PROJREPO="tremor-rs/tremor-runtime"        ORGNAME=tremor            PORT=3066 ICON=tremor         GRAFSUFF=tremor         GA="-" ./devel/deploy_proj.sh || exit 84
  elif [ "$proj" = "metal3" ]
  then
    PROJ=metal3              PROJDB=metal3         PROJREPO="metal3-io/baremetal-operator"    ORGNAME="Metal³"          PORT=3067 ICON=metal3         GRAFSUFF=metal3         GA="-" ./devel/deploy_proj.sh || exit 85
  elif [ "$proj" = "porter" ]
  then
    PROJ=porter              PROJDB=porter         PROJREPO="getporter/porter"                ORGNAME=Porter            PORT=3068 ICON=porter         GRAFSUFF=porter         GA="-" ./devel/deploy_proj.sh || exit 86
  elif [ "$proj" = "openyurt" ]
  then
    PROJ=openyurt            PROJDB=openyurt       PROJREPO="openyurtio/openyurt"             ORGNAME=OpenYurt          PORT=3069 ICON=openyurt       GRAFSUFF=openyurt       GA="-" ./devel/deploy_proj.sh || exit 87
  elif [ "$proj" = "openservicemesh" ]
  then
    PROJ=openservicemesh     PROJDB=openservicemesh PROJREPO="openservicemesh/osm"            ORGNAME="Open Service Mesh" PORT=3070 ICON=openservicemesh GRAFSUFF=openservicemesh GA="-" ./devel/deploy_proj.sh || exit 88
  elif [ "$proj" = "keylime" ]
  then
    PROJ=keylime             PROJDB=keylime        PROJREPO="keylime/keylime"                 ORGNAME=Keylime           PORT=3071 ICON=keylime        GRAFSUFF=keylime        GA="-" ./devel/deploy_proj.sh || exit 89
  elif [ "$proj" = "schemahero" ]
  then
    PROJ=schemahero          PROJDB=schemahero     PROJREPO="schemahero/schemahero"           ORGNAME=SchemaHero        PORT=3072 ICON=schemahero     GRAFSUFF=schemahero     GA="-" ./devel/deploy_proj.sh || exit 91
  elif [ "$proj" = "cdk8s" ]
  then
    PROJ=cdk8s               PROJDB=cdk8s          PROJREPO="cdk8s-team/cdk8s" ORGNAME="Cloud Development Kit for Kubernetes" PORT=3073 ICON=cdk8s     GRAFSUFF=cdk8s          GA="-" ./devel/deploy_proj.sh || exit 92
  elif [ "$proj" = "certmanager" ]
  then
    PROJ=certmanager         PROJDB=certmanager    PROJREPO="cert-manager/cert-manager"       ORGNAME="cert-manager"    PORT=3074 ICON=certmanager    GRAFSUFF=certmanager    GA="-" ./devel/deploy_proj.sh || exit 93
  elif [ "$proj" = "openkruise" ]
  then
    PROJ=openkruise          PROJDB=openkruise     PROJREPO="openkruise/kruise"               ORGNAME=OpenKruise        PORT=3075 ICON=openkruise     GRAFSUFF=openkruise     GA="-" ./devel/deploy_proj.sh || exit 94
  elif [ "$proj" = "tinkerbell" ]
  then
    PROJ=tinkerbell          PROJDB=tinkerbell     PROJREPO="tinkerbell/tink"                 ORGNAME=Tinkerbell        PORT=3076 ICON=tinkerbell     GRAFSUFF=tinkerbell     GA="-" ./devel/deploy_proj.sh || exit 95
  elif [ "$proj" = "pravega" ]
  then
    PROJ=pravega             PROJDB=pravega        PROJREPO="pravega/pravega"                 ORGNAME=Pravega           PORT=3077 ICON=pravega        GRAFSUFF=pravega        GA="-" ./devel/deploy_proj.sh || exit 96
  elif [ "$proj" = "kyverno" ]
  then
    PROJ=kyverno             PROJDB=kyverno        PROJREPO="kyverno/kyverno"                 ORGNAME=Kyverno           PORT=3078 ICON=kyverno        GRAFSUFF=kyverno        GA="-" ./devel/deploy_proj.sh || exit 97
  elif [ "$proj" = "gitopswg" ]
  then
    PROJ=gitopswg            PROJDB=gitopswg       PROJREPO="cncf/tag-app-delivery"           ORGNAME="GitOps WG" PORT=3079 ICON=gitopswg   GRAFSUFF=gitopswg       GA="-" ./devel/deploy_proj.sh || exit 98
  elif [ "$proj" = "piraeus" ]
  then
    PROJ=piraeus             PROJDB=piraeus        PROJREPO="piraeusdatastore/piraeus-operator" ORGNAME=Piraeus-Datastore PORT=3080 ICON=piraeus      GRAFSUFF=piraeus        GA="-" ./devel/deploy_proj.sh || exit 99
  elif [ "$proj" = "k8dash" ]
  then
    PROJ=k8dash              PROJDB=k8dash         PROJREPO="skooner-k8s/skooner"             ORGNAME=Skooner           PORT=3081 ICON=k8dash         GRAFSUFF=k8dash         GA="-" ./devel/deploy_proj.sh || exit 100
  elif [ "$proj" = "athenz" ]
  then
    PROJ=athenz              PROJDB=athenz         PROJREPO="AthenZ/athenz"                   ORGNAME=Athenz            PORT=3082 ICON=athenz         GRAFSUFF=athenz         GA="-" ./devel/deploy_proj.sh || exit 101
  elif [ "$proj" = "kubeovn" ]
  then
    PROJ=kubeovn             PROJDB=kubeovn        PROJREPO="kubeovn/kube-ovn"                ORGNAME=Kube-OVN          PORT=3083 ICON=kubeovn        GRAFSUFF=kubeovn        GA="-" ./devel/deploy_proj.sh || exit 102
  elif [ "$proj" = "curiefense" ]
  then
    PROJ=curiefense          PROJDB=curiefense     PROJREPO="curiefense/curiefense"           ORGNAME=Curiefense        PORT=3084 ICON=curiefense     GRAFSUFF=curiefense     GA="-" ./devel/deploy_proj.sh || exit 103
  elif [ "$proj" = "distribution" ]
  then
    PROJ=distribution        PROJDB=distribution   PROJREPO="distribution/distribution"       ORGNAME=Distribution      PORT=3085 ICON=distribution   GRAFSUFF=distribution   GA="-" ./devel/deploy_proj.sh || exit 104
  elif [ "$proj" = "ingraind" ]
  then
    PROJ=ingraind            PROJDB=ingraind       PROJREPO="foniod/foniod"                   ORGNAME=Foniod            PORT=3086 ICON=ingraind       GRAFSUFF=ingraind       GA="-" ./devel/deploy_proj.sh || exit 105
  elif [ "$proj" = "kuberhealthy" ]
  then
    PROJ=kuberhealthy        PROJDB=kuberhealthy   PROJREPO="kuberhealthy/kuberhealthy"       ORGNAME=Kuberhealthy      PORT=3087 ICON=kuberhealthy   GRAFSUFF=kuberhealthy   GA="-" ./devel/deploy_proj.sh || exit 106
  elif [ "$proj" = "k8gb" ]
  then
    PROJ=k8gb                PROJDB=k8gb           PROJREPO="k8gb-io/k8gb"                    ORGNAME=K8GB              PORT=3088 ICON=k8gb           GRAFSUFF=k8gb           GA="-" ./devel/deploy_proj.sh || exit 107
  elif [ "$proj" = "trickster" ]
  then
    PROJ=trickster           PROJDB=trickster      PROJREPO="trickstercache/trickster"        ORGNAME=Trickster         PORT=3089 ICON=trickster      GRAFSUFF=trickster      GA="-" ./devel/deploy_proj.sh || exit 108
  elif [ "$proj" = "emissaryingress" ]
  then
    PROJ=emissaryingress     PROJDB=emissaryingress PROJREPO="emissary-ingress/emissary"      ORGNAME=Emissary-ingress  PORT=3090 ICON=emissaryingress GRAFSUFF=emissaryingress GA="-" ./devel/deploy_proj.sh || exit 109
  elif [ "$proj" = "wasmedge" ]
  then
    PROJ=wasmedge            PROJDB=wasmedge        PROJREPO="WasmEdge/WasmEdge"              ORGNAME='WasmEdge Runtime' PORT=3091 ICON=wasmedge      GRAFSUFF=wasmedge       GA="-" ./devel/deploy_proj.sh || exit 110
  elif [ "$proj" = "chaosblade" ]
  then
    PROJ=chaosblade          PROJDB=chaosblade      PROJREPO="chaosblade-io/chaosblade"       ORGNAME=ChaosBlade        PORT=3092 ICON=chaosblade     GRAFSUFF=chaosblade     GA="-" ./devel/deploy_proj.sh || exit 111
  elif [ "$proj" = "vineyard" ]
  then
    PROJ=vineyard            PROJDB=vineyard        PROJREPO="v6d-io/v6d"                     ORGNAME=Vineyard          PORT=3093 ICON=vineyard       GRAFSUFF=vineyard       GA="-" ./devel/deploy_proj.sh || exit 112
  elif [ "$proj" = "antrea" ]
  then
    PROJ=antrea              PROJDB=antrea          PROJREPO="antrea-io/antrea"               ORGNAME=Antrea            PORT=3094 ICON=antrea         GRAFSUFF=antrea         GA="-" ./devel/deploy_proj.sh || exit 113
  elif [ "$proj" = "fluid" ]
  then
    PROJ=fluid               PROJDB=fluid           PROJREPO="fluid-cloudnative/fluid"        ORGNAME=Fluid             PORT=3095 ICON=fluid          GRAFSUFF=fluid          GA="-" ./devel/deploy_proj.sh || exit 114
  elif [ "$proj" = "submariner" ]
  then
    PROJ=submariner          PROJDB=submariner      PROJREPO="submariner-io/submariner"       ORGNAME=Submariner        PORT=3096 ICON=submariner     GRAFSUFF=submariner     GA="-" ./devel/deploy_proj.sh || exit 115
  elif [ "$proj" = "pixie" ]
  then
    PROJ=pixie               PROJDB=pixie           PROJREPO="pixie-io/pixie"                 ORGNAME=Pixie             PORT=3097 ICON=pixie          GRAFSUFF=pixie          GA="-" ./devel/deploy_proj.sh || exit 116
  elif [ "$proj" = "meshery" ]
  then
    PROJ=meshery             PROJDB=meshery         PROJREPO="meshery/meshery"                ORGNAME=Meshery           PORT=3098 ICON=meshery        GRAFSUFF=meshery        GA="-" ./devel/deploy_proj.sh || exit 117
  elif [ "$proj" = "servicemeshperformance" ]
  then
    PROJ=servicemeshperformance PROJDB=servicemeshperformance PROJREPO="service-mesh-performance/service-mesh-performance" ORGNAME='Service Mesh Performance' PORT=3099 ICON=servicemeshperformance GRAFSUFF=servicemeshperformance GA="-" ./devel/deploy_proj.sh || exit 118
  elif [ "$proj" = "kubevela" ]
  then
    PROJ=kubevela            PROJDB=kubevela        PROJREPO="kubevela/kubevela"              ORGNAME=KubeVela          PORT=3100 ICON=kubevela       GRAFSUFF=kubevela       GA="-" ./devel/deploy_proj.sh || exit 119
  elif [ "$proj" = "kubevip" ]
  then
    PROJ=kubevip             PROJDB=kubevip         PROJREPO="kube-vip/kube-vip"              ORGNAME=kube-vip          PORT=3101 ICON=kubevip        GRAFSUFF=kubevip        GA="-" ./devel/deploy_proj.sh || exit 120
  elif [ "$proj" = "kubedl" ]
  then
    PROJ=kubedl              PROJDB=kubedl          PROJREPO="kubedl-io/kubedl"               ORGNAME=KubeDL            PORT=3102 ICON=kubedl         GRAFSUFF=kubedl         GA="-" ./devel/deploy_proj.sh || exit 121
  elif [ "$proj" = "krustlet" ]
  then
    PROJ=krustlet            PROJDB=krustlet        PROJREPO="krustlet/krustlet"              ORGNAME=Krustlet          PORT=3103 ICON=krustlet       GRAFSUFF=krustlet       GA="-" ./devel/deploy_proj.sh || exit 122
  elif [ "$proj" = "krator" ]
  then
    PROJ=krator              PROJDB=krator          PROJREPO="krator-rs/krator"               ORGNAME=Krator            PORT=3104 ICON=krator         GRAFSUFF=krator         GA="-" ./devel/deploy_proj.sh || exit 123
  elif [ "$proj" = "oras" ]
  then
    PROJ=oras                PROJDB=oras            PROJREPO="oras-project/oras"              ORGNAME=ORAS              PORT=3105 ICON=oras           GRAFSUFF=oras           GA="-" ./devel/deploy_proj.sh || exit 124
  elif [ "$proj" = "wasmcloud" ]
  then
    PROJ=wasmcloud           PROJDB=wasmcloud       PROJREPO="wasmCloud/wasmCloud"            ORGNAME=wasmCloud         PORT=3106 ICON=wasmcloud      GRAFSUFF=wasmcloud      GA="-" ./devel/deploy_proj.sh || exit 125
  elif [ "$proj" = "akri" ]
  then
    PROJ=akri                PROJDB=Akri            PROJREPO="project-akri/akri"              ORGNAME=Akri              PORT=3107 ICON=akri           GRAFSUFF=akri           GA="-" ./devel/deploy_proj.sh || exit 126
  elif [ "$proj" = "metallb" ]
  then
    PROJ=metallb             PROJDB=metallb         PROJREPO="metallb/metallb"                ORGNAME=MetalLB           PORT=3108 ICON=metallb        GRAFSUFF=metallb        GA="-" ./devel/deploy_proj.sh || exit 127
  elif [ "$proj" = "karmada" ]
  then
    PROJ=karmada             PROJDB=karmada         PROJREPO="karmada-io/karmada"             ORGNAME=Karmada           PORT=3109 ICON=karmada        GRAFSUFF=karmada        GA="-" ./devel/deploy_proj.sh || exit 128
  elif [ "$proj" = "inclavarecontainers" ]
  then
    PROJ=inclavarecontainers PROJDB=inclavarecontainers PROJREPO="inclavare-containers/inclavare-containers" ORGNAME="Inclavare Containers" PORT=3110 ICON=inclavarecontainers GRAFSUFF=inclavarecontainers GA="-" ./devel/deploy_proj.sh || exit 129
  elif [ "$proj" = "superedge" ]
  then
    PROJ=superedge           PROJDB=superedge      PROJREPO="superedge/superedge"             ORGNAME=SuperEdge         PORT=3111 ICON=superedge      GRAFSUFF=superedge      GA="-" ./devel/deploy_proj.sh || exit 130
  elif [ "$proj" = "cilium" ]
  then
    PROJ=cilium              PROJDB=cilium         PROJREPO="cilium/cilium"                   ORGNAME=Cilium            PORT=3112 ICON=cilium         GRAFSUFF=cilium         GA="-" ./devel/deploy_proj.sh || exit 131
  elif [ "$proj" = "dapr" ]
  then
    PROJ=dapr                PROJDB=dapr           PROJREPO="dapr/dapr"                       ORGNAME=Dapr              PORT=3113 ICON=dapr           GRAFSUFF=dapr           GA="-" ./devel/deploy_proj.sh || exit 132
  elif [ "$proj" = "openelb" ]
  then
    PROJ=openelb             PROJDB=openelb        PROJREPO="openelb/openelb"                 ORGNAME=OpenELB           PORT=3114 ICON=openelb        GRAFSUFF=openelb        GA="-" ./devel/deploy_proj.sh || exit 133
  elif [ "$proj" = "openclustermanagement" ]
  then
    PROJ=openclustermanagement PROJDB=openclustermanagement PROJREPO="open-cluster-management-io/api" ORGNAME="Open Cluster Management" PORT=3115 ICON=openclustermanagement GRAFSUFF=openclustermanagement GA="-" ./devel/deploy_proj.sh || exit 134
  elif [ "$proj" = "vscodek8stools" ]
  then
    PROJ=vscodek8stools      PROJDB=vscodek8stools PROJREPO="vscode-kubernetes-tools/vscode-kubernetes-tools" ORGNAME="VS Code Kubernetes Tools" PORT=3116 ICON=vscodek8stools GRAFSUFF=vscodek8stools GA="-" ./devel/deploy_proj.sh || exit 135
  elif [ "$proj" = "nocalhost" ]
  then
    PROJ=nocalhost           PROJDB=nocalhost      PROJREPO="nocalhost/nocalhost"             ORGNAME=Nocalhost         PORT=3117 ICON=nocalhost      GRAFSUFF=nocalhost      GA="-" ./devel/deploy_proj.sh || exit 136
  elif [ "$proj" = "kubearmor" ]
  then
    PROJ=kubearmor           PROJDB=kubearmor      PROJREPO="kubearmor/KubeArmor"             ORGNAME=KubeArmor         PORT=3118 ICON=kubearmor      GRAFSUFF=kubearmor      GA="-" ./devel/deploy_proj.sh || exit 137
  elif [ "$proj" = "k8up" ]
  then
    PROJ=k8up                PROJDB=k8up           PROJREPO="k8up-io/k8up"                    ORGNAME=K8up              PORT=3119 ICON=k8up           GRAFSUFF=k8up           GA="-" ./devel/deploy_proj.sh || exit 138
  elif [ "$proj" = "kubers" ]
  then
    PROJ=kubers              PROJDB=kubers         PROJREPO="kube-rs/kube"                    ORGNAME=kube-rs           PORT=3120 ICON=kubers         GRAFSUFF=kubers         GA="-" ./devel/deploy_proj.sh || exit 139
  elif [ "$proj" = "devfile" ]
  then
    PROJ=devfile             PROJDB=devfile        PROJREPO="devfile/api"                     ORGNAME=devfile           PORT=3121 ICON=devfile        GRAFSUFF=devfile        GA="-" ./devel/deploy_proj.sh || exit 140
  elif [ "$proj" = "knative" ]
  then
    PROJ=knative             PROJDB=knative        PROJREPO="knative/serving"                 ORGNAME=Knative           PORT=3122 ICON=knative        GRAFSUFF=knative        GA="-" ./devel/deploy_proj.sh || exit 41
  elif [ "$proj" = "fabedge" ]
  then
    PROJ=fabedge             PROJDB=fabedge        PROJREPO="FabEdge/fabedge"                 ORGNAME=FabEdge           PORT=3123 ICON=fabedge        GRAFSUFF=fabedge        GA="-" ./devel/deploy_proj.sh || exit 42
  elif [ "$proj" = "confidentialcontainers" ]
  then
    PROJ=confidentialcontainers PROJDB=confidentialcontainers PROJREPO="confidential-containers/operator" ORGNAME='Confidential Containers' PORT=3124 ICON=confidentialcontainers GRAFSUFF=confidentialcontainers GA="-" ./devel/deploy_proj.sh || exit 43
  elif [ "$proj" = "openfunction" ]
  then
    PROJ=openfunction        PROJDB=openfunction   PROJREPO="OpenFunction/OpenFunction"       ORGNAME=OpenFunction      PORT=3125 ICON=openfunction   GRAFSUFF=openfunction   GA="-" ./devel/deploy_proj.sh || exit 44
  elif [ "$proj" = "teller" ]
  then
    PROJ=teller              PROJDB=teller         PROJREPO="tellerops/teller"                ORGNAME=Teller            PORT=3126 ICON=teller         GRAFSUFF=teller         GA="-" ./devel/deploy_proj.sh || exit 45
  elif [ "$proj" = "sealer" ]
  then
    PROJ=sealer              PROJDB=sealer         PROJREPO="sealerio/sealer"                 ORGNAME=sealer            PORT=3127 ICON=sealer         GRAFSUFF=sealer         GA="-" ./devel/deploy_proj.sh || exit 46
  elif [ "$proj" = "clusterpedia" ]
  then
    PROJ=clusterpedia        PROJDB=clusterpedia   PROJREPO="clusterpedia-io/clusterpedia"    ORGNAME=Clusterpedia      PORT=3128 ICON=clusterpedia   GRAFSUFF=clusterpedia   GA="-" ./devel/deploy_proj.sh || exit 47
  elif [ "$proj" = "opencost" ]
  then
    PROJ=opencost            PROJDB=opencost       PROJREPO="opencost/opencost"               ORGNAME=OpenCost          PORT=3129 ICON=opencost       GRAFSUFF=opencost       GA="-" ./devel/deploy_proj.sh || exit 48
  elif [ "$proj" = "aerakimesh" ]
  then
    PROJ=aerakimesh          PROJDB=aerakimesh     PROJREPO="aeraki-mesh/aeraki"              ORGNAME='Aeraki Mesh'     PORT=3130 ICON=aerakimesh     GRAFSUFF=aerakimesh     GA="-" ./devel/deploy_proj.sh || exit 49
  elif [ "$proj" = "curve" ]
  then
    PROJ=curve               PROJDB=curve          PROJREPO="opencurve/curve"                 ORGNAME=Curve             PORT=3131 ICON=curve          GRAFSUFF=curve          GA="-" ./devel/deploy_proj.sh || exit 50
  elif [ "$proj" = "openfeature" ]
  then
    PROJ=openfeature         PROJDB=openfeature    PROJREPO="open-feature/spec"               ORGNAME=OpenFeature       PORT=3132 ICON=openfeature    GRAFSUFF=openfeature    GA="-" ./devel/deploy_proj.sh || exit 51
  elif [ "$proj" = "kubewarden" ]
  then
    PROJ=kubewarden          PROJDB=kubewarden     PROJREPO="kubewarden/kubewarden-controller" ORGNAME=kubewarden       PORT=3133 ICON=kubewarden     GRAFSUFF=kubewarden     GA="-" ./devel/deploy_proj.sh || exit 52
  elif [ "$proj" = "devstream" ]
  then
    PROJ=devstream           PROJDB=devstream      PROJREPO="devstream-io/devstream"          ORGNAME=DevStream         PORT=3134 ICON=devstream      GRAFSUFF=devstream      GA="-" ./devel/deploy_proj.sh || exit 53
  elif [ "$proj" = "hexapolicyorchestrator" ]
  then
    PROJ=hexapolicyorchestrator PROJDB=hexapolicyorchestrator PROJREPO="hexa-org/policy-orchestrator" ORGNAME="Hexa Policy Orchestrator" PORT=3135 ICON=hexapolicyorchestrator GRAFSUFF=hexapolicyorchestrator GA="-" ./devel/deploy_proj.sh || exit 54
  elif [ "$proj" = "konveyor" ]
  then
    PROJ=konveyor            PROJDB=konveyor       PROJREPO="konveyor/operator"               ORGNAME=Konveyor          PORT=3136 ICON=konveyor       GRAFSUFF=konveyor       GA="-" ./devel/deploy_proj.sh || exit 55
  elif [ "$proj" = "armada" ]
  then
    PROJ=armada              PROJDB=armada         PROJREPO="armadaproject/armada"            ORGNAME=Armada            PORT=3137 ICON=armada         GRAFSUFF=armada         GA="-" ./devel/deploy_proj.sh || exit 56
  elif [ "$proj" = "externalsecretsoperator" ]
  then
    PROJ=externalsecretsoperator PROJDB=externalsecretsoperator PROJREPO="external-secrets/external-secrets" ORGNAME="External Secrets Operator" PORT=3138 ICON=externalsecretsoperator GRAFSUFF=externalsecretsoperator GA="-" ./devel/deploy_proj.sh || exit 57
  elif [ "$proj" = "serverlessdevs" ]
  then
         PROJ=serverlessdevs PROJDB=serverlessdevs PROJREPO="Serverless-Devs/Serverless-Devs" ORGNAME='Serverless Devs' PORT=3139 ICON=serverlessdevs GRAFSUFF=serverlessdevs GA="-" ./devel/deploy_proj.sh || exit 141
  elif [ "$proj" = "containerssh" ]
  then
         PROJ=containerssh   PROJDB=containerssh   PROJREPO="ContainerSSH/ContainerSSH"       ORGNAME=ContainerSSH      PORT=3140 ICON=containerssh   GRAFSUFF=containerssh   GA="-" ./devel/deploy_proj.sh || exit 142
  elif [ "$proj" = "openfga" ]
  then
         PROJ=openfga        PROJDB=openfga        PROJREPO="openfga/openfga"                 ORGNAME=OpenFGA           PORT=3141 ICON=openfga        GRAFSUFF=openfga        GA="-" ./devel/deploy_proj.sh || exit 143
  elif [ "$proj" = "kured" ]
  then
         PROJ=kured          PROJDB=kured          PROJREPO="kubereboot/kured"                ORGNAME=Kured             PORT=3142 ICON=kured          GRAFSUFF=kured          GA="-" ./devel/deploy_proj.sh || exit 144
  elif [ "$proj" = "carvel" ]
  then
         PROJ=carvel         PROJDB=carvel         PROJREPO="carvel-dev/ytt"                  ORGNAME=Carvel            PORT=3143 ICON=carvel         GRAFSUFF=carvel         GA="-" ./devel/deploy_proj.sh || exit 145
  elif [ "$proj" = "lima" ]
  then
         PROJ=lima           PROJDB=lima           PROJREPO="lima-vm/lima"                    ORGNAME=Lima              PORT=3144 ICON=lima           GRAFSUFF=lima           GA="-" ./devel/deploy_proj.sh || exit 146
  elif [ "$proj" = "istio" ]
  then
    PROJ=istio               PROJDB=istio          PROJREPO="istio/istio"                     ORGNAME=Istio             PORT=3221 ICON=istio          GRAFSUFF=istio          GA="-"  ./devel/deploy_proj.sh || exit 34
  elif [ "$proj" = "merbridge" ]
  then
    PROJ=merbridge           PROJDB=merbridge      PROJREPO="merbridge/merbridge"             ORGNAME=Merbridge         PORT=3222 ICON=merbridge      GRAFSUFF=merbridge      GA="-"  ./devel/deploy_proj.sh || exit 147
  elif [ "$proj" = "devspace" ]
  then
    PROJ=devspace            PROJDB=devspace       PROJREPO="devspace-sh/devspace"            ORGNAME=DevSpace          PORT=3223 ICON=devspace       GRAFSUFF=devspace       GA="-"  ./devel/deploy_proj.sh || exit 148
  elif [ "$proj" = "capsule" ]
  then
    PROJ=capsule             PROJDB=capsule        PROJREPO="projectcapsule/capsule"          ORGNAME=capsule           PORT=3224 ICON=capsule        GRAFSUFF=capsule        GA="-"  ./devel/deploy_proj.sh || exit 149
  elif [ "$proj" = "zot" ]
  then
    PROJ=zot                 PROJDB=zot            PROJREPO="project-zot/zot"                 ORGNAME=zot               PORT=3225 ICON=zot            GRAFSUFF=zot            GA="-" ./devel/deploy_proj.sh || exit 150
  elif [ "$proj" = "paralus" ]
  then
    PROJ=paralus             PROJDB=paralus        PROJREPO="paralus/paralus"                 ORGNAME=paralus           PORT=3226 ICON=paralus        GRAFSUFF=paralus        GA="-" ./devel/deploy_proj.sh || exit 151
  elif [ "$proj" = "carina" ]
  then
    PROJ=carina              PROJDB=carina         PROJREPO="carina-io/carina"                ORGNAME=Carina            PORT=3227 ICON=carina         GRAFSUFF=carina         GA="-" ./devel/deploy_proj.sh || exit 152
  elif [ "$proj" = "ko" ]
  then
    PROJ=ko                  PROJDB=ko             PROJREPO="ko-build/ko"                     ORGNAME=ko                PORT=3228 ICON=ko             GRAFSUFF=ko             GA="-" ./devel/deploy_proj.sh || exit 153
  elif [ "$proj" = "opcr" ]
  then
    PROJ=opcr                PROJDB=opcr           PROJREPO="opcr-io/policy"                  ORGNAME=OPCR              PORT=3229 ICON=opcr           GRAFSUFF=opcr           GA="-" ./devel/deploy_proj.sh || exit 154
  elif [ "$proj" = "werf" ]
  then
    PROJ=werf                PROJDB=werf           PROJREPO="werf/werf"                       ORGNAME=werf              PORT=3230 ICON=werf           GRAFSUFF=werf           GA="-" ./devel/deploy_proj.sh || exit 155
  elif [ "$proj" = "kubescape" ]
  then
    PROJ=kubescape           PROJDB=kubescape      PROJREPO="kubescape/kubescape"             ORGNAME=Kubescape         PORT=3231 ICON=kubescape      GRAFSUFF=kubescape      GA="-" ./devel/deploy_proj.sh || exit 156
  elif [ "$proj" = "inspektorgadget" ]
  then
    PROJ=inspektorgadget     PROJDB=inspektorgadget PROJREPO="inspektor-gadget/inspektor-gadget" ORGNAME="Inspektor Gadget" PORT=3232 ICON=inspektorgadget GRAFSUFF=inspektorgadget GA="-" ./devel/deploy_proj.sh || exit 157
  elif [ "$proj" = "clusternet" ]
  then
    PROJ=clusternet          PROJDB=clusternet     PROJREPO="clusternet/clusternet"           ORGNAME=Clusternet        PORT=3233 ICON=clusternet     GRAFSUFF=clusternet     GA="-" ./devel/deploy_proj.sh || exit 158
  elif [ "$proj" = "keycloak" ]
  then
    PROJ=keycloak            PROJDB=keycloak       PROJREPO="keycloak/keycloak"               ORGNAME=Keycloak          PORT=3234 ICON=keycloak       GRAFSUFF=keycloak       GA="-" ./devel/deploy_proj.sh || exit 159
  elif [ "$proj" = "sops" ]
  then
    PROJ=sops                PROJDB=sops           PROJREPO="getsops/sops"                    ORGNAME=SOPS              PORT=3235 ICON=soprs          GRAFSUFF=sops           GA="-" ./devel/deploy_proj.sh || exit 160
  elif [ "$proj" = "headlamp" ]
  then
    PROJ=headlamp            PROJDB=headlamp       PROJREPO="kubernetes-sigs/headlamp"        ORGNAME=Headlamp          PORT=3236 ICON=headlamp       GRAFSUFF=headlamp       GA="-" ./devel/deploy_proj.sh || exit 161
  elif [ "$proj" = "slimtoolkit" ]
  then
    PROJ=slimtoolkit         PROJDB=slimtoolkit    PROJREPO="slimtoolkit/slim"                ORGNAME=SlimToolkit       PORT=3237 ICON=slimtoolkit    GRAFSUFF=slimtoolkit    GA="-" ./devel/deploy_proj.sh || exit 162
  elif [ "$proj" = "kepler" ]
  then
    PROJ=kepler              PROJDB=kepler         PROJREPO="sustainable-computing-io/kepler" ORGNAME=Kepler            PORT=3238 ICON=kepler         GRAFSUFF=kepler         GA="-" ./devel/deploy_proj.sh || exit 163
  elif [ "$proj" = "pipecd" ]
  then
    PROJ=pipecd              PROJDB=pipecd         PROJREPO="pipe-cd/pipecd"                  ORGNAME=PipeCD            PORT=3239 ICON=pipecd         GRAFSUFF=pipecd         GA="-" ./devel/deploy_proj.sh || exit 164
  elif [ "$proj" = "eraser" ]
  then
    PROJ=eraser              PROJDB=eraser         PROJREPO="eraser-dev/eraser"               ORGNAME=Eraser            PORT=3240 ICON=eraser         GRAFSUFF=eraser         GA="-" ./devel/deploy_proj.sh || exit 165
  elif [ "$proj" = "xline" ]
  then
    PROJ=xline               PROJDB=xline          PROJREPO="xline-kv/Xline"                  ORGNAME=Xline             PORT=3241 ICON=xline          GRAFSUFF=xline          GA="-" ./devel/deploy_proj.sh || exit 166
  elif [ "$proj" = "hwameistor" ]
  then
    PROJ=hwameistor          PROJDB=hwameistor     PROJREPO="hwameistor/hwameistor"           ORGNAME=Hwameistor        PORT=3242 ICON=hwameistor     GRAFSUFF=hwameistor     GA="-" ./devel/deploy_proj.sh || exit 167
  elif [ "$proj" = "kpt" ]
  then
    PROJ=kpt                 PROJDB=kpt            PROJREPO="kptdev/kpt"                      ORGNAME=kpt               PORT=3243 ICON=kpt            GRAFSUFF=kpt            GA="-" ./devel/deploy_proj.sh || exit 168
  elif [ "$proj" = "microcks" ]
  then
    PROJ=microcks            PROJDB=microcks       PROJREPO="microcks/microcks"               ORGNAME=Microcks          PORT=3244 ICON=microcks       GRAFSUFF=microcks       GA="-" ./devel/deploy_proj.sh || exit 169
  elif [ "$proj" = "kubeclipper" ]
  then
    PROJ=kubeclipper         PROJDB=kubeclipper    PROJREPO="kubeclipper/kubeclipper"         ORGNAME=Kubeclipper       PORT=3245 ICON=kubeclipper    GRAFSUFF=kubeclipper    GA="-" ./devel/deploy_proj.sh || exit 170
  elif [ "$proj" = "kubeflow" ]
  then
    PROJ=kubeflow            PROJDB=kubeflow       PROJREPO="kubeflow/kubeflow"               ORGNAME=Kubeflow          PORT=3246 ICON=kubeflow       GRAFSUFF=kubeflow       GA="-" ./devel/deploy_proj.sh || exit 171
  elif [ "$proj" = "copacetic" ]
  then
    PROJ=copacetic           PROJDB=copacetic      PROJREPO="project-copacetic/copacetic"     ORGNAME=Copacetic         PORT=3247 ICON=copacetic      GRAFSUFF=copacetic      GA="-" ./devel/deploy_proj.sh || exit 172
  elif [ "$proj" = "loggingoperator" ]
  then
    PROJ=loggingoperator     PROJDB=loggingoperator PROJREPO="kube-logging/logging-operator"  ORGNAME="Logging Operator" PORT=3248 ICON=loggingoperator GRAFSUFF=loggingoperator GA="-" ./devel/deploy_proj.sh || exit 173
  elif [ "$proj" = "kanister" ]
  then
    PROJ=kanister            PROJDB=kanister       PROJREPO="kanisterio/kanister"             ORGNAME=Kanister          PORT=3249 ICON=kanister       GRAFSUFF=kanister       GA="-" ./devel/deploy_proj.sh || exit 174
  elif [ "$proj" = "kcp" ]
  then
    PROJ=kcp                 PROJDB=kcp            PROJREPO="kcp-dev/kcp"                     ORGNAME=kcp               PORT=3250 ICON=kcp            GRAFSUFF=kcp            GA="-" ./devel/deploy_proj.sh || exit 175
  elif [ "$proj" = "kcl" ]
  then
    PROJ=kcl                 PROJDB=kcl            PROJREPO="kcl-lang/kcl"                    ORGNAME=KCL               PORT=3251 ICON=kcl            GRAFSUFF=kcl            GA="-" ./devel/deploy_proj.sh || exit 176
  elif [ "$proj" = "kubeburner" ]
  then
    PROJ=kubeburner          PROJDB=kubeburner     PROJREPO="kube-burner/kube-burner"         ORGNAME='kube-burner'     PORT=3252 ICON=kubeburner     GRAFSUFF=kubeburner     GA="-" ./devel/deploy_proj.sh || exit 177
  elif [ "$proj" = "kuasar" ]
  then
    PROJ=kuasar              PROJDB=kuasar         PROJREPO="kuasar-io/kuasar"                ORGNAME=Kuasar            PORT=3253 ICON=kuasar         GRAFSUFF=kuasar         GA="-" ./devel/deploy_proj.sh || exit 178
  elif [ "$proj" = "krknchaos" ]
  then
    PROJ=krknchaos           PROJDB=krknchaos      PROJREPO="krkn-chaos/krkn"                 ORGNAME=KrknChaos         PORT=3254 ICON=krknchaos      GRAFSUFF=krknchaos      GA="-" ./devel/deploy_proj.sh || exit 179
  elif [ "$proj" = "kubestellar" ]
  then
    PROJ=kubestellar         PROJDB=kubestellar    PROJREPO="kubestellar/kubestellar"         ORGNAME=Kubestellar       PORT=3255 ICON=kubestellar    GRAFSUFF=kubestellar    GA="-" ./devel/deploy_proj.sh || exit 180
  elif [ "$proj" = "easegress" ]
  then
    PROJ=easegress           PROJDB=easegress      PROJREPO="easegress-io/easegress"          ORGNAME=easegress         PORT=3256 ICON=easegress      GRAFSUFF=easegress      GA="-" ./devel/deploy_proj.sh || exit 181
  elif [ "$proj" = "spiderpool" ]
  then
    PROJ=spiderpool          PROJDB=spiderpool     PROJREPO="spidernet-io/spiderpool"         ORGNAME=Spiderpool        PORT=3257 ICON=spiderpool     GRAFSUFF=spiderpool     GA="-" ./devel/deploy_proj.sh || exit 182
  elif [ "$proj" = "k8sgpt" ]
  then
    PROJ=k8sgpt              PROJDB=k8sgpt         PROJREPO="k8sgpt-ai/k8sgpt"                ORGNAME=K8sGPT            PORT=3258 ICON=k8sgpt         GRAFSUFF=k8sgpt         GA="-" ./devel/deploy_proj.sh || exit 183
  elif [ "$proj" = "kubeslice" ]
  then
    PROJ=kubeslice           PROJDB=kubeslice      PROJREPO="kubeslice/kubeslice"             ORGNAME=Kubeslice         PORT=3259 ICON=kubeslice      GRAFSUFF=kubeslice      GA="-" ./devel/deploy_proj.sh               || exit 184
  elif [ "$proj" = "connect" ]
  then
    PROJ=connect             PROJDB=connect        PROJREPO="connectrpc/connect-go"           ORGNAME=Connect           PORT=3260 ICON=connect        GRAFSUFF=connect         GA="-" ./devel/deploy_proj.sh              || exit 185
  elif [ "$proj" = "kairos" ]
  then
    PROJ=kairos              PROJDB=kairos         PROJREPO="kairos-io/kairos"                ORGNAME=Kairos            PORT=3261 ICON=kairos         GRAFSUFF=kairos         GA="-" ./devel/deploy_proj.sh               || exit 186
  elif [ "$proj" = "kubean" ]
  then
    PROJ=kubean              PROJDB=kubean         PROJREPO="kubean-io/kubean"                ORGNAME=Kubean            PORT=3262 ICON=kubean         GRAFSUFF=kubean         GA="-" ./devel/deploy_proj.sh               || exit 187
  elif [ "$proj" = "koordinator" ]
  then
    PROJ=koordinator         PROJDB=koordinator    PROJREPO="koordinator-sh/koordinator"      ORGNAME=Koordinator       PORT=3263 ICON=koordinator    GRAFSUFF=koordinator    GA="-" ./devel/deploy_proj.sh               || exit 188
  elif [ "$proj" = "radius" ]
  then
    PROJ=radius              PROJDB=radius         PROJREPO="radius-project/radius"           ORGNAME=Radius            PORT=3264 ICON=radius         GRAFSUFF=radius         GA="-" ./devel/deploy_proj.sh               || exit 189
  elif [ "$proj" = "bankvaults" ]
  then
    PROJ=bankvaults          PROJDB=bankvaults     PROJREPO="bank-vaults/bank-vaults"         ORGNAME='Bank-Vaults'     PORT=3265 ICON=bankvaults     GRAFSUFF=bankvaults     GA="-" ./devel/deploy_proj.sh               || exit 190
  elif [ "$proj" = "atlantis" ]
  then
    PROJ=atlantis            PROJDB=atlantis       PROJREPO="runatlantis/atlantis"            ORGNAME=Atlantis          PORT=3266 ICON=atlantis       GRAFSUFF=atlantis       GA="-" ./devel/deploy_proj.sh               || exit 191
  elif [ "$proj" = "stacker" ]
  then
    PROJ=stacker             PROJDB=stacker        PROJREPO="project-stacker/stacker"         ORGNAME=Stacker           PORT=3267 ICON=stacker        GRAFSUFF=stacker        GA="-" ./devel/deploy_proj.sh               || exit 192
  elif [ "$proj" = "trestlegrc" ]
  then
    PROJ=trestlegrc          PROJDB=trestlegrc     PROJREPO="oscal-compass/compliance-trestle" ORGNAME=TrestleGRC       PORT=3268 ICON=trestlegrc     GRAFSUFF=trestlegrc     GA="-" ./devel/deploy_proj.sh               || exit 193
  elif [ "$proj" = "kuadrant" ]
  then
    PROJ=kuadrant            PROJDB=kuadrant       PROJREPO="Kuadrant/authorino"              ORGNAME=Kuadrant          PORT=3269 ICON=kuadrant       GRAFSUFF=kuadrant       GA="-" ./devel/deploy_proj.sh               || exit 194
  elif [ "$proj" = "opengemini" ]
  then
    PROJ=opengemini          PROJDB=opengemini     PROJREPO="openGemini/openGemini"           ORGNAME=openGemini        PORT=3270 ICON=opengemini     GRAFSUFF=opengemini     GA="-" ./devel/deploy_proj.sh               || exit 195
  elif [ "$proj" = "score" ]
  then
    PROJ=score               PROJDB=score          PROJREPO="score-spec/score-go"             ORGNAME=Score             PORT=3271 ICON=score          GRAFSUFF=score          GA="-" ./devel/deploy_proj.sh               || exit 196
  elif [ "$proj" = "bpfman" ]
  then
    PROJ=bpfman              PROJDB=bpfman         PROJREPO="bpfman/bpfman"                   ORGNAME=bpfman            PORT=3272 ICON=bpfman         GRAFSUFF=bpfman         GA="-" ./devel/deploy_proj.sh               || exit 197
  elif [ "$proj" = "loxilb" ]
  then
    PROJ=loxilb              PROJDB=loxilb         PROJREPO="loxilb-io/loxilb"                ORGNAME=LoxiLB            PORT=3273 ICON=loxilb         GRAFSUFF=loxilb         GA="-" ./devel/deploy_proj.sh               || exit 198
  elif [ "$proj" = "cartography" ]
  then
    PROJ=cartography         PROJDB=cartography    PROJREPO="cartography-cncf/cartography"    ORGNAME=Cartography       PORT=3274 ICON=cartography    GRAFSUFF=cartography    GA="-" ./devel/deploy_proj.sh               || exit 199
  elif [ "$proj" = "perses" ]
  then
    PROJ=perses              PROJDB=perses         PROJREPO="perses/perses"                   ORGNAME=Perses            PORT=3275 ICON=perses         GRAFSUFF=perses         GA="-" ./devel/deploy_proj.sh               || exit 200
  elif [ "$proj" = "ratify" ]
  then
    PROJ=ratify              PROJDB=ratify         PROJREPO="ratify-project/ratify"           ORGNAME=ratify            PORT=3276 ICON=ratify         GRAFSUFF=ratify         GA="-" ./devel/deploy_proj.sh               || exit 201
  elif [ "$proj" = "hami" ]
  then
    PROJ=hami                PROJDB=hami           PROJREPO="Project-HAMi/HAMi"               ORGNAME=HAMi              PORT=3277 ICON=hami           GRAFSUFF=hami           GA="-" ./devel/deploy_proj.sh               || exit 202
  elif [ "$proj" = "shipwrightcncf" ]
  then
    PROJ=shipwrightcncf      PROJDB=shipwrightcncf PROJREPO="shipwright-io/build"             ORGNAME=Shipwright        PORT=3278 ICON=shipwrightcncf GRAFSUFF=shipwrightcncf GA="-" ./devel/deploy_proj.sh               || exit 203
  elif [ "$proj" = "flatcar" ]
  then
    PROJ=flatcar             PROJDB=flatcar        PROJREPO="flatcar/mantle"                  ORGNAME=Flatcar           PORT=3279 ICON=flatcar        GRAFSUFF=flatcar        GA="-" ./devel/deploy_proj.sh               || exit 204
  elif [ "$proj" = "kusionstack" ]
  then
    PROJ=kusionstack         PROJDB=kusionstack    PROJREPO="KusionStack/kusion"              ORGNAME=KusionStack       PORT=3280 ICON=kusionstack    GRAFSUFF=kusionstack    GA="-" ./devel/deploy_proj.sh               || exit 205
  elif [ "$proj" = "youki" ]
  then
    PROJ=youki               PROJDB=youki          PROJREPO="youki-dev/youki"                 ORGNAME=Youki             PORT=3281 ICON=youki          GRAFSUFF=youki          GA="-" ./devel/deploy_proj.sh               || exit 206
  elif [ "$proj" = "kaito" ]
  then
    PROJ=kaito               PROJDB=kaito          PROJREPO="kaito-project/kaito"             ORGNAME=KAITO             PORT=3282 ICON=kaito          GRAFSUFF=kaito          GA="-" ./devel/deploy_proj.sh               || exit 207
  elif [ "$proj" = "sermant" ]
  then
    PROJ=sermant             PROJDB=sermant        PROJREPO="sermant-io/Sermant"              ORGNAME=Sermant           PORT=3283 ICON=sermant        GRAFSUFF=sermant        GA="-" ./devel/deploy_proj.sh               || exit 208
  elif [ "$proj" = "kmesh" ]
  then
    PROJ=kmesh               PROJDB=kmesh          PROJREPO="kmesh-net/kmesh"                 ORGNAME=Kmesh             PORT=3284 ICON=kmesh          GRAFSUFF=kmesh          GA="-" ./devel/deploy_proj.sh               || exit 209
  elif [ "$proj" = "ovnkubernetes" ]
  then
    PROJ=ovnkubernetes       PROJDB=ovnkubernetes  PROJREPO="ovn-kubernetes/ovn-kubernetes"   ORGNAME='OVN-Kubernetes'  PORT=3285 ICON=ovnkubernetes  GRAFSUFF=ovnkubernetes  GA="-" ./devel/deploy_proj.sh               || exit 210
elif ( [ "$proj" = "tratteria" ] || [ "$proj" = "tokenetes" ] )
  then
    PROJ=tratteria           PROJDB=tratteria      PROJREPO="tokenetes/tokenetes"             ORGNAME='Tokenetes'       PORT=3286 ICON=tratteria      GRAFSUFF=tratteria      GA="-" ./devel/deploy_proj.sh               || exit 211
  elif [ "$proj" = "spin" ]
  then
    PROJ=spin                PROJDB=spin           PROJREPO="spinframework/spin"              ORGNAME='Spin'            PORT=3287 ICON=spin           GRAFSUFF=spin           GA="-" ./devel/deploy_proj.sh               || exit 212
  elif [ "$proj" = "spinkube" ]
  then
    PROJ=spinkube            PROJDB=spinkube       PROJREPO="spinframework/spin-operator"     ORGNAME='SpinKube'        PORT=3288 ICON=spinkube       GRAFSUFF=spinkube       GA="-" ./devel/deploy_proj.sh               || exit 213
  elif [ "$proj" = "slimfaas" ]
  then
    PROJ=slimfaas            PROJDB=slimfaas       PROJREPO="SlimPlanet/SlimFaas"             ORGNAME='SlimFaaS'        PORT=3289 ICON=slimfaas       GRAFSUFF=slimfaas       GA="-" ./devel/deploy_proj.sh               || exit 214
  elif [ "$proj" = "container2wasm" ]
  then
    PROJ=container2wasm      PROJDB=container2wasm PROJREPO="container2wasm/container2wasm"   ORGNAME='container2wasm'  PORT=3290 ICON=container2wasm GRAFSUFF=container2wasm GA="-" ./devel/deploy_proj.sh               || exit 215
  elif [ "$proj" = "k0s" ]
  then
    PROJ=k0s                 PROJDB=k0s            PROJREPO="k0sproject/k0s"                  ORGNAME='k0s'             PORT=3291 ICON=k0s            GRAFSUFF=k0s            GA="-" ./devel/deploy_proj.sh               || exit 216
  elif [ "$proj" = "runmenotebooks" ]
  then
    PROJ=runmenotebooks      PROJDB=runmenotebooks PROJREPO="runmedev/runme"                  ORGNAME='Runme Notebooks' PORT=3292 ICON=runmenotebooks GRAFSUFF=runmenotebooks GA="-" ./devel/deploy_proj.sh               || exit 217
  elif [ "$proj" = "cloudnativepg" ]
  then
    PROJ=cloudnativepg       PROJDB=cloudnativepg  PROJREPO="cloudnative-pg/cloudnative-pg"   ORGNAME='CloudNativePG'   PORT=3293 ICON=cloudnativepg  GRAFSUFF=coloudnativepg GA="-" ./devel/deploy_proj.sh               || exit 218
  elif [ "$proj" = "kubefleet" ]
  then
    PROJ=kubefleet           PROJDB=kubefleet      PROJREPO="Azure/fleet"                     ORGNAME='KubeFleet'       PORT=3294 ICON=kubefleet      GRAFSUFF=kubefleet      GA="-" ./devel/deploy_proj.sh               || exit 219
  elif [ "$proj" = "podmandesktop" ]
  then
    PROJ=podmandesktop       PROJDB=podmandesktop  PROJREPO="podmat-desktop/podman-desktop"   ORGNAME='Podman Desktop'  PORT=3295 ICON=podmandesktop  GRAFSUFF=podmandesktop  GA="-" ./devel/deploy_proj.sh               || exit 220
  elif [ "$proj" = "podmancontainertools" ]
  then
    PROJ=podmancontainertools PROJDB=podmancontainertools PROJREPO="containers/podman"        ORGNAME='Podman Container Tools' PORT=3296 ICON=podmancontainertools GRAFSUFF=podmancontainertools GA="-" ./devel/deploy_proj.sh || exit 221
  elif [ "$proj" = "bootc" ]
  then
    PROJ=bootc               PROJDB=bootc          PROJREPO="bootc-dev/bootc"                 ORGNAME='bootc'           PORT=3297 ICON=bootc          GRAFSUFF=bootc          GA="-" ./devel/deploy_proj.sh               || exit 222
  elif [ "$proj" = "composefs" ]
  then
    PROJ=composefs           PROJDB=composefs      PROJREPO="composefs/composefs"             ORGNAME='composefs'       PORT=3298 ICON=composefs      GRAFSUFF=composefs      GA="-" ./devel/deploy_proj.sh               || exit 223
  elif [ "$proj" = "drasi" ]
  then
    PROJ=drasi               PROJDB=drasi          PROJREPO="drasi-project/drasi-platform"    ORGNAME='Drasi'           PORT=3299 ICON=drasi          GRAFSUFF=drasi          GA="-" ./devel/deploy_proj.sh               || exit 224
  elif [ "$proj" = "interlink" ]
  then
    PROJ=interlink           PROJDB=interlink      PROJREPO="interlink-hq/interLink"          ORGNAME='Interlink'       PORT=3300 ICON=interlink      GRAFSUFF=interlink      GA="-" ./devel/deploy_proj.sh               || exit 225
  elif [ "$proj" = "cozystack" ]
  then
    PROJ=cozystack           PROJDB=cozystack      PROJREPO="cozystack/cozystack"             ORGNAME='CozyStack'       PORT=3301 ICON=cozystack      GRAFSUFF=cozystack      GA="-" ./devel/deploy_proj.sh               || exit 226
  elif [ "$proj" = "kgateway" ]
  then
    PROJ=kgateway            PROJDB=kgateway       PROJREPO="kgateway-dev/kgateway"           ORGNAME='kgateway'        PORT=3302 ICON=kgateway       GRAFSUFF=kgateway       GA="-" ./devel/deploy_proj.sh               || exit 227
  elif [ "$proj" = "kitops" ]
  then
    PROJ=kitops              PROJDB=kitops         PROJREPO="kitops-ml/kitops"                ORGNAME='KitOps'          PORT=3303 ICON=kitops         GRAFSUFF=kitops         GA="-" ./devel/deploy_proj.sh               || exit 228
  elif [ "$proj" = "hyperlight" ]
  then
    PROJ=hyperlight          PROJDB=hyperlight     PROJREPO="hyperlight-dev/hyperlight"       ORGNAME='Hyperlight'      PORT=3304 ICON=hyperlight     GRAFSUFF=hyperlight     GA="-" ./devel/deploy_proj.sh               || exit 229
  elif [ "$proj" = "opentofu" ]
  then
    PROJ=opentofu            PROJDB=opentofu       PROJREPO="opentofu/opentofu"               ORGNAME='OpenTofu'        PORT=3305 ICON=opentofu       GRAFSUFF=opentofu       GA="-" ./devel/deploy_proj.sh               || exit 230
  elif [ "$proj" = "cadence" ]
  then
    PROJ=cadence             PROJDB=cadence        PROJREPO="cadence-workflow/cadence"        ORGNAME='Cadence'         PORT=3306 ICON=cadence        GRAFSUFF=cadence        GA="-" ./devel/deploy_proj.sh               || exit 231
  elif [ "$proj" = "kagent" ]
  then
    PROJ=kagent              PROJDB=kagent         PROJREPO="kagent-dev/kagent"               ORGNAME='kagent'          PORT=3307 ICON=kagent         GRAFSUFF=kagent         GA="-" ./devel/deploy_proj.sh               || exit 232
  elif [ "$proj" = "urunc" ]
  then
    PROJ=urunc               PROJDB=urunc          PROJREPO="urunc-dev/urunc"                 ORGNAME='urunc'           PORT=3308 ICON=urunc          GRAFSUFF=urunc          GA="-" ./devel/deploy_proj.sh               || exit 233
  elif [ "$proj" = "xregistry" ]
  then
    PROJ=xregistry           PROJDB=xregistry      PROJREPO="xregistry/server"                ORGNAME='xRegistry'       PORT=3309 ICON=xregistry      GRAFSUFF=xregistry      GA="-" ./devel/deploy_proj.sh               || exit 234
  elif [ "$proj" = "modelpack" ]
  then
    PROJ=modelpack           PROJDB=modelpack      PROJREPO="model-pack/model-spec"           ORGNAME=ModelPack         PORT=3310 ICON=modelpack      GRAFSUFF=modelpack      GA="-" ./devel/deploy_proj.sh               || exit 235
  elif [ "$proj" = "kserve" ]
  then
    PROJ=kserve              PROJDB=kserve         PROJREPO="kserve/kserve"                   ORGNAME=KServe            PORT=3311 ICON=kserve         GRAFSUFF=kserve         GA="-" ./devel/deploy_proj.sh               || exit 236
  elif [ "$proj" = "oauth2proxy" ]
  then
    PROJ=oauth2proxy         PROJDB=oauth2proxy    PROJREPO="oauth2-proxy/oauth2-proxy"       ORGNAME="OAuth2-Proxy"    PORT=3312 ICON=oauth2proxy    GRAFSUFF=oauth2proxy    GA="-" ./devel/deploy_proj.sh               || exit 237
  elif [ "$proj" = "oxia" ]
  then
    PROJ=oxia                PROJDB=oxia           PROJREPO="oxia-db/oxia"                    ORGNAME=Oxia              PORT=3313 ICON=oxia           GRAFSUFF=oxia           GA="-" ./devel/deploy_proj.sh               || exit 238
  elif [ "$proj" = "holmesgpt" ]
  then
    PROJ=holemsgpt           PROJDB=holmesgpt      PROJREPO="HolmesGPT/holmesgpt"             ORGNAME=HolmesGPT         PORT=3314 ICON=holmesgpt      GRAFSUFF=holmesgpt      GA="-" ./devel/deploy_proj.sh               || exit 239
  elif [ "$proj" = "cedarpolicy" ]
  then
    PROJ=cedarpolicy         PROJDB=cedarpolicy    PROJREPO="cedar-policy/cedar"              ORGNAME="Cedar Policy"    PORT=3315 ICON=cedarpolicy    GRAFSUFF=cedarpolicy    GA="-" ./devel/deploy_proj.sh               || exit 240
  elif [ "$proj" = "dalec" ]
  then
    PROJ=dalec               PROJDB=dalec          PROJREPO="project-dalec/dalec"             ORGNAME=Dalce             PORT=3316 ICON=dalce          GRAFSUFF=dalec          GA="-" ./devel/deploy_proj.sh               || exit 241
  elif [ "$proj" = "opencontainers" ]
  then
    PROJ=opencontainers      PROJDB=opencontainers PROJREPO="opencontainers/runc"             ORGNAME=OCI               PORT=3220 ICON="-"            GRAFSUFF=opencontainers GA="-" ./devel/deploy_proj.sh               || exit 32
  elif [ "$proj" = "cncf" ]
  then
    PROJ=cncf                PROJDB=cncf           PROJREPO="cncf/landscapeapp"               ORGNAME=CNCF              PORT=3255 ICON=cncf           GRAFSUFF=cncf           GA="-"  ./devel/deploy_proj.sh              || exit 33
  elif [ "$proj" = "sam" ]
  then
    PROJ=sam                 PROJDB=sam            PROJREPO="awslabs/serverless-application-model" ORGNAME="AWS SAM"    PORT=3224 ICON=cncf           GRAFSUFF=sam            GA="-"               ./devel/deploy_proj.sh || exit 54
  elif [ "$proj" = "azf" ]
  then
    PROJ=azf                 PROJDB=azf            PROJREPO="Azure/azure-webjobs-sdk"         ORGNAME=AZF               PORT=3225 ICON=cncf           GRAFSUFF=azf            GA="-"               ./devel/deploy_proj.sh || exit 55
  elif [ "$proj" = "riff" ]
  then
    PROJ=riff                PROJDB=riff           PROJREPO="projectriff/riff"                ORGNAME="Pivotal Riff"    PORT=3226 ICON=cncf           GRAFSUFF=riff           GA="-"               ./devel/deploy_proj.sh || exit 56
  elif [ "$proj" = "fn" ]
  then
    PROJ=fn                  PROJDB=fn             PROJREPO="fnproject/fn"                    ORGNAME="Oracle Fn"       PORT=3227 ICON=cncf           GRAFSUFF=fn             GA="-"               ./devel/deploy_proj.sh || exit 57
  elif [ "$proj" = "openwhisk" ]
  then
    PROJ=openwhisk           PROJDB=openwhisk      PROJREPO="apache/openwhisk"                ORGNAME="Apache OpenWhisk" PORT=3228 ICON=cncf          GRAFSUFF=openwhisk      GA="-"               ./devel/deploy_proj.sh || exit 58
  elif [ "$proj" = "openfaas" ]
  then
    PROJ=openfaas            PROJDB=openfaas       PROJREPO="openfaas/faas"                   ORGNAME="OpenFaaS"        PORT=3229 ICON=cncf           GRAFSUFF=openfaas       GA="-"               ./devel/deploy_proj.sh || exit 59
  elif [ "$proj" = "cii" ]
  then
    PROJ=cii                 PROJDB=cii            PROJREPO="not/used"                        ORGNAME="CII"             PORT=3130 ICON=cncf           GRAFSUFF=cii            GA="-"               ./devel/deploy_proj.sh || exit 62
  elif [ "$proj" = "prestodb" ]
  then
    PROJ=prestodb            PROJDB=prestodb       PROJREPO="presto/prestodb"                 ORGNAME="Presto"          PORT=3131 ICON=prestodb       GRAFSUFF=prestodb       GA="-"               ./devel/deploy_proj.sh || exit 63
  elif [ "$proj" = "godotengine" ]
  then
    PROJ=godotengine         PROJDB=godotengine    PROJREPO="godotengine/godot"               ORGNAME="Godot Engine"    PORT=3132 ICON=godotengine    GRAFSUFF=godotengine    GA="-"               ./devel/deploy_proj.sh || exit 90
  elif [ "$proj" = "all" ]
  then
    PROJ=all                 PROJDB=allprj         PROJREPO="not/used"                        ORGNAME="All CNCF"        PORT=3254 ICON=cncf           GRAFSUFF=all            GA="-" ./devel/deploy_proj.sh || exit 36
  else
    echo "Unknown project: $proj"
    exit 28
  fi
done

if [ -z "$SKIPCERT" ]
then
  export CERT=1
fi

if [ -z "$SKIPWWW" ]
then
  WWW=1 ./devel/create_www.sh || exit 37
fi
if [ -z "$SKIPVARS" ]
then
  ./devel/vars_all.sh || exit 38
fi

if [ -z "$SKIPICONS" ]
then
  ./devel/icons_all.sh || exit 47
fi
if [ -z "$SKIPMAKE" ]
then
  rm -f /tmp/deploy.wip 2>/dev/null
  make install || exit 48
fi

echo "$0: All deployments finished"
