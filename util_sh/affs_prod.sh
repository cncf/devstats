#!/bin/bash
if [ -z "${PG_PASS}" ]
then
  echo "You need to set PG_PASS environment variable to run this script"
  exit 1
fi

ONLY="kubernetes prometheus opentracing" ./devel/all_affs.sh || exit 2
GHA2DB_RECENT_RANGE="4 hours" GHA2DB_TMOFFSET="-4" devstats

ONLY="fluentd linkerd grpc coredns containerd cni envoy jaeger notary" ./devel/all_affs.sh || exit 3
GHA2DB_RECENT_RANGE="4 hours" GHA2DB_TMOFFSET="-4" devstats

ONLY="tuf rook vitess nats opa spiffe spire cloudevents telepresence helm" ./devel/all_affs.sh || exit 4
GHA2DB_RECENT_RANGE="4 hours" GHA2DB_TMOFFSET="-4" devstats

ONLY="harbor etcd tikv cortex buildpacks falco dragonfly virtualkubelet kubeedge brigade keylime" ./devel/all_affs.sh || exit 5
GHA2DB_RECENT_RANGE="4 hours" GHA2DB_TMOFFSET="-4" devstats

ONLY="schemahero cdk8s certmanager openkruise tinkerbell pravega kyverno gitopswg piraeus k8dash athenz kubeovn distribution" ./devel/all_affs.sh || exit 6
GHA2DB_RECENT_RANGE="4 hours" GHA2DB_TMOFFSET="-4" devstats

ONLY="distribution kuberhealthy k8gb trickster emissaryingress wasmedge chaosblade vineyard antrea fluid submariner" ./devel/all_affs.sh || exit 7
GHA2DB_RECENT_RANGE="4 hours" GHA2DB_TMOFFSET="-4" devstats

ONLY="pixie meshery servicemeshperformance kubevela kubevip kubedl krustlet oras wasmcloud akri metallb karmada" ./devel/all_affs.sh || exit 8
GHA2DB_RECENT_RANGE="4 hours" GHA2DB_TMOFFSET="-4" devstats

ONLY="inclavarecontainers superedge cilium dapr openelb openclustermanagement vscodek8stools nocalhost kubearmor" ./devel/all_affs.sh || exit 9
GHA2DB_RECENT_RANGE="4 hours" GHA2DB_TMOFFSET="-4" devstats

ONLY="k8up kubers devfile knative fabedge confidentialcontainers openfunction teller sealer clusterpedia opencost" ./devel/all_affs.sh || exit 10
GHA2DB_RECENT_RANGE="4 hours" GHA2DB_TMOFFSET="-4" devstats

ONLY="aerakimesh curve openfeature kubewarden devstream hexapolicyorchestrator konveyor armada externalsecretsoperator serverlessdevs" ./devel/all_affs.sh || exit 11
GHA2DB_RECENT_RANGE="4 hours" GHA2DB_TMOFFSET="-4" devstats

ONLY="containerssh openfga kured carvel lima istio merbridge devspace capsule zot paralus carina ko opcr werf kubescape inspektorgadget clusternet" ./devel/all_affs.sh || exit 12
GHA2DB_RECENT_RANGE="4 hours" GHA2DB_TMOFFSET="-4" devstats

ONLY="crio networkservicemesh opentelemetry thanos flux intoto strimzi kubevirt longhorn chubaofs keda" ./devel/all_affs.sh || exit 13
GHA2DB_RECENT_RANGE="4 hours" GHA2DB_TMOFFSET="-4" devstats

ONLY="keycloak sops headlamp slimtoolkit kepler pipecd eraser xline hwameistor kpt microcks kubeclipper kubeflow copacetic loggingoperator kanister kcp kcl" ./devel/all_affs.sh || exit 14
GHA2DB_RECENT_RANGE="4 hours" GHA2DB_TMOFFSET="-4" devstats

ONLY="kubeburner kuasar krknchaos kubestellar easegress spiderpool k8sgpt kubeslice connect kairos kubean koordinator radius" ./devel/all_affs.sh || exit 15
GHA2DB_RECENT_RANGE="4 hours" GHA2DB_TMOFFSET="-4" devstats

ONLY="bankvaults atlantis stacker trestlegrc kuadrant opengemini score bpfman loxilb cartography perses ratify hami shipwrightcncf flatcar" ./devel/all_affs.sh || exit 16
GHA2DB_RECENT_RANGE="4 hours" GHA2DB_TMOFFSET="-4" devstats

ONLY="openebs kusionstack youki kaito sermant kmesh ovnkubernetes tratteria spin spinkube slimfaas container2wasm k0s runmenotebooks cloudnativepg" ./devel/all_affs.sh || exit 17
GHA2DB_RECENT_RANGE="4 hours" GHA2DB_TMOFFSET="-4" devstats

ONLY="kubefleet podmandesktop podmancontainertools bootc composefs drasi interlink cozystack kgateway kitops hyperlight opentofu" ./devel/all_affs.sh || exit 18
GHA2DB_RECENT_RANGE="4 hours" GHA2DB_TMOFFSET="-4" devstats

ONLY="smi argo volcano cnigenie keptn kudo cloudcustodian dex litmuschaos artifacthub kuma parsec bfe crossplane" ./devel/all_affs.sh || exit 19
GHA2DB_RECENT_RANGE="4 hours" GHA2DB_TMOFFSET="-4" devstats

ONLY="contour operatorframework chaosmesh serverlessworkflow k3s backstage tremor metal3 porter openyurt openservicemesh" ./devel/all_affs.sh || exit 20
GHA2DB_RECENT_RANGE="4 hours" GHA2DB_TMOFFSET="-4" devstats

ONLY="all" ./devel/all_affs.sh || exit 21
GHA2DB_RECENT_RANGE="4 hours" GHA2DB_TMOFFSET="-4" devstats

./devel/columns_all.sh
