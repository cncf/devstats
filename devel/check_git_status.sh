#!/bin/bash
cd ..
for f in devstats devstatscode devstats-docker-images devstats-docker-lf devstats-example devstats-helm devstats-helm-lf devstats-k8s-lf devstats-reports devstats-helm-example devstats-helm-graphql devstats-kubernetes-dashboard devstats-landscape-sync
do
  if [ ! -d "${f}" ]
  then
    git clone "https://github.com/cncf/${f}" || exit 1
  fi
  cd "${f}"
  echo ">>>>> status: $f <<<<<"
  git status
  cd ..
done
