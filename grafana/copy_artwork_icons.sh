#!/bin/bash
# ARTWORK
# This script assumes that You have cncf/artwork and cdfoundation/artwork cloned in ~/dev/cncf/artwork and ~/dev/cdfoundation/artwork and grafana/create_images.sh was run just before it.
. ./devel/all_projs.sh || exit 2
for proj in $all
do
  if ( [ "$proj" = "opencontainers" ] || [ "$proj" = "cdf" ] || [ "$proj" = "prestodb" ] || [ "$proj" = "godotengine" ] || [ "$proj" = "linux" ] || [ "$proj" = "zephyr" ] || [ "$proj" = "graphql" ] || [ "$proj" = "graphqljs" ] || [ "$proj" = "graphiql" ] || [ "$proj" = "expressgraphql" ] || [ "$proj" = "graphqlspec" ] )
  then
    continue
  fi
  suff=$proj
  icon=$proj
  mid="icon"
  dash='-'
  if [ "$suff" = "kubernetes" ]
  then
    suff="k8s"
  fi
  if [ "$icon" = "all" ]
  then
    icon="cncf"
  fi
  if [ "$icon" = "allcdf" ]
  then
    icon="cdf"
  fi
  if [ "$icon" = "intoto" ]
  then
    icon="in-toto"
  fi
  if [ "$icon" = "smi" ]
  then
    icon="servicemeshinterface"
  fi
  if [ "$icon" = "litmuschaos" ]
  then
    icon="litmus"
  fi
  if [ "$icon" = "certmanager" ]
  then
    icon="cert-manager"
  fi
  if [ "$icon" = "kubeovn" ]
  then
    icon="kube-ovn"
  fi
  if [ "$icon" = "gitops" ]
  then
    icon="opengitops"
  fi
  if [ "$icon" = "emissaryingress" ]
  then
    icon="emissary-ingress"
  fi
  if [ "$icon" = "distribution" ]
  then
    icon="cncf-distribution"
  fi
  if [ "$icon" = "wasmedge" ]
  then
    icon="wasm-edge-runtime"
  fi
  if [ "$icon" = "k8dash" ]
  then
    icon="skooner"
  fi
  if [ "$icon" = "ingraind" ]
  then
    icon="fonio"
  fi
  if [ "$icon" = "openmetrics" ]
  then
    icon="prometheus"
  fi
  if [ "$icon" = "inclavarecontainers" ]
  then
    icon="inclavare"
  fi
  if [ "$icon" = "kubers" ]
  then
    icon="kube-rs"
  fi
  if [ "$icon" = "serverlessdevs" ]
  then
    icon="serverless-devs"
  fi
  if [ "$icon" = "inspektorgadget" ]
  then
    icon="inspektor-gadget"
  fi
  if [ "$icon" = "kubeburner" ]
  then
    icon="kube-burner"
  fi
  if [ "$icon" = "loggingoperator" ]
  then
    icon="logging-operator"
  fi
  if [ "$icon" = "krknchaos" ]
  then
    icon="krkn"
  fi
  if [ "$icon" = "connect" ]
  then
    icon="connect-rpc"
    mid=''
    dash=''
  fi
  if [ "$icon" = "bankvaults" ]
  then
    icon="bank-vaults"
  fi
  if [ "$icon" = "shipwrightcncf" ]
  then
    icon="shipwright"
  fi
  if [ "$icon" = "tratteria" ]
  then
    icon="tokenetes"
  fi
  if [ "$icon" = "runmenotebooks" ]
  then
    icon="runme"
  fi
  if [ "$icon" = "ovnkubernetes" ]
  then
    icon="ovn-kubernetes"
  fi
  # TODO: remove when we have icons
  if ( [ "$icon" = "xregistry" ] || [ "$icon" = "modelpack" ] || [ "$icon" = "cadence" ] || [ "$icon" = "kagent" ] || [ "$icon" = "kgateway" ] || [ "$icon" = "container2wasm" ] || [ "$icon" = "k0s" ] || [ "$icon" = "kubefleet" ] || [ "$icon" = "podmandesktop" ] || [ "$icon" = "podmancontainertools" ] || [ "$icon" = "bootc" ] || [ "$icon" = "composefs" ] || [ "$icon" = "kanister" ] || [ "$icon" = "kubeclipper" ] || [ "$icon" = "sealer" ] || [ "$icon" = "openelb" ] || [ "$icon" = "cartography" ] || [ "$icon" = "trestlegrc" ] || [ "$icon" = "opengemini" ] || [ "$icon" = "containerssh" ] || [ "$icon" = "lima" ] || [ "$icon" = "hexapolicyorchestrator" ] || [ "$icon" = "externalsecretsoperator" ] || [ "$icon" = "devstream" ] || [ "$icon" = "vscodek8stools" ] || [ "$icon" = "kubevip" ] || [ "$icon" = "cnigenie" ] || [ "$icon" = "contrib" ] || [ "$icon" = "sam" ] || [ "$icon" = "azf" ] || [ "$icon" = "riff" ] || [ "$icon" = "fn" ] || [ "$icon" = "openwhisk" ] || [ "$icon" = "openfaas" ] || [ "$icon" = "cii" ] )
  then
    icon="cncf"
  fi
  icontype=`./devel/get_icon_type.sh "$proj"` || exit 1
  iconorg=`./devel/get_icon_source.sh "$proj"` || exit 18
  path=$icon
  if ( [ "$path" = "devstats" ] || [ "$path" = "cncf" ] || [ "$path" = "gitopswg" ] )
  then
    path="other/$icon"
  elif ( [ "$icon" = "devstream" ] || [ "$icon" = "curve" ] || [ "$icon" = "nocalhost" ] || [ "$icon" = "superedge" ] || [ "$icon" = "kubedl" ] || [ "$icon" = "teller" ] || [ "$icon" = "merbridge" ] || [ "$icon" = "skooner" ] || [ "$icon" = "rkt" ] || [ "$icon" = "brigade" ] || [ "$icon" = "opentracing" ] || [ "$icon" = "openservicemesh" ] || [ "$icon" = "servicemeshinterface" ] || [ "$icon" = "curiefense" ] || [ "$icon" = "krator" ] || [ "$icon" = "fonio" ] || [ "$icon" = "krustlet" ] )
  then
    # 2025-05-23: Archivals: DevStream, OpenELB, Krustlet, Curve, FabEdge, Nocalhost, Superedge, KubeDL, Sealer, Teller, Merbridge, Skooner, CNI-Genie
    path="archived/$icon"
  elif [ "$iconorg" = "cncf" ]
  then
    path="projects/$icon"
  fi
  if [ "$icon" = "skooner" ]
  then
    icon=Skooner
  fi
  if [ "$path" = "projects/notary" ]
  then
    icon="notary-project"
  fi
  # echo "Proj: $proj, icon: $icon, path: $path, icon type: $icontype:, icon org: $iconorg, suffix: $suff"
  cp "$HOME/dev/$iconorg/artwork/$path/icon/$icontype/$icon$dash$mid-$icontype.svg" "/usr/share/grafana.$suff/public/img/grafana_icon.svg" || exit 2
  cp "$HOME/dev/$iconorg/artwork/$path/icon/$icontype/$icon$dash$mid-$icontype.svg" "/usr/share/grafana.$suff/public/img/grafana_com_auth_icon.svg" || exit 3
  cp "$HOME/dev/$iconorg/artwork/$path/icon/$icontype/$icon$dash$mid-$icontype.svg" "/usr/share/grafana.$suff/public/img/grafana_net_logo.svg" || exit 4
  cp "$HOME/dev/$iconorg/artwork/$path/icon/$icontype/$icon$dash$mid-$icontype.svg" "/usr/share/grafana.$suff/public/img/grafana_mask_icon.svg" || exit 5
  if [ "$icon" = "kubernetes" ]
  then
    icon="k8s"
  fi
  if [ "$icon" = "in-toto" ]
  then
    icon="intoto"
  fi
  if [ "$icon" = "servicemeshinterface" ]
  then
    icon="smi"
  fi
  cp -n "/usr/share/grafana.$suff/public/img/fav32.png" "/usr/share/grafana.$suff/public/img/fav32.png.bak" || exit 6
  cp "grafana/img/${icon}32.png" "/usr/share/grafana.$suff/public/img/fav32.png" || exit 7
  cp -n "/usr/share/grafana.$suff/public/img/fav16.png" "/usr/share/grafana.$suff/public/img/fav16.png.bak" || exit 8
  cp "grafana/img/${icon}32.png" "/usr/share/grafana.$suff/public/img/fav16.png" || exit 9
  cp -n "/usr/share/grafana.$suff/public/img/fav_dark_16.png" "/usr/share/grafana.$suff/public/img/fav_dark_16.png.bak" || exit 10
  cp "grafana/img/${icon}32.png" "/usr/share/grafana.$suff/public/img/fav_dark_16.png" || exit 11
  cp -n "/usr/share/grafana.$suff/public/img/fav_dark_32.png" "/usr/share/grafana.$suff/public/img/fav_dark_32.png.bak" || exit 12
  cp "grafana/img/${icon}32.png" "/usr/share/grafana.$suff/public/img/fav_dark_32.png" || exit 13

  mkdir "/usr/share/grafana.$suff/public/img/projects" 2>/dev/null
  # Copy all other projects images
  cp grafana/img/*.svg "/usr/share/grafana.$suff/public/img/projects/" || exit 18

done

# Special cases
# Special OCI case (not a CNCF project)
if [[ $all = *"opencontainers"* ]]
then
  cp ./images/OCI.svg /usr/share/grafana.opencontainers/public/img/grafana_icon.svg || exit 14
  cp ./images/OCI.svg /usr/share/grafana.opencontainers/public/img/grafana_com_auth_icon.svg || exit 15
  cp ./images/OCI.svg /usr/share/grafana.opencontainers/public/img/grafana_net_logo.svg || exit 16
  cp ./images/OCI.svg /usr/share/grafana.opencontainers/public/img/grafana_mask_icon.svg || exit 17
fi

# Special Presto DB case (not a CNCF project)
if [[ $all = *"prestodb"* ]]
then
  cp ./images/presto-logo-stacked.svg /usr/share/grafana.prestodb/public/img/grafana_icon.svg || exit 19
  cp ./images/presto-logo-stacked.svg /usr/share/grafana.prestodb/public/img/grafana_com_auth_icon.svg || exit 20
  cp ./images/presto-logo-stacked.svg /usr/share/grafana.prestodb/public/img/grafana_net_logo.svg || exit 21
  cp ./images/presto-logo-stacked.svg /usr/share/grafana.prestodb/public/img/grafana_mask_icon.svg || exit 22
fi

# Special Godot Engine case (not a CNCF project)
if [[ $all = *"godotengine"* ]]
then
  cp ./images/godotengine-logo-stacked.svg /usr/share/grafana.godotengine/public/img/grafana_icon.svg || exit 23
  cp ./images/godotengine-logo-stacked.svg /usr/share/grafana.godotengine/public/img/grafana_com_auth_icon.svg || exit 24
  cp ./images/godotengine-logo-stacked.svg /usr/share/grafana.godotengine/public/img/grafana_net_logo.svg || exit 25
  cp ./images/godotengine-logo-stacked.svg /usr/share/grafana.godotengine/public/img/grafana_mask_icon.svg || exit 26
fi

echo 'OK'
