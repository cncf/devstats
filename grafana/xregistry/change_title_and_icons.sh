#!/bin/bash
# GRAFANA_DATA=/usr/share/grafana.xregistry/
# SKIPVIM=1 skip text replace part"
if [ -z "${GRAFANA_DATA}" ]
then
  echo "You need to set GRAFANA_DATA environment variable to run this script"
  exit 1
fi
if [ -z "${SKIPVIM}" ]
then
  for f in `find ${GRAFANA_DATA} -type f -exec grep -l "'Grafana - '" "{}" \; | sort | uniq`
  do
    ls -l "$f"
    sed -i "s|'Grafana - '|'xRegistry DevStats - '|g" "$f"
  done
  for f in `find ${GRAFANA_DATA} -type f -exec grep -l '"Grafana - "' "{}" \; | sort | uniq`
  do
    ls -l "$f"
    sed -i 's|"Grafana - "|"xRegistry DevStats - "|g' "$f"
  done
  for f in `find ${GRAFANA_DATA} -type f -exec grep -l "' - Grafana'" "{}" \; | sort | uniq`
  do
    ls -l "$f"
    sed -i "s|' - Grafana'|' - xRegistry DevStats'|g" "$f"
  done
  for f in `find ${GRAFANA_DATA} -type f -exec grep -l '" - Grafana"' "{}" \; | sort | uniq`
  do
    ls -l "$f"
    sed -i 's|" - Grafana"|" - xRegistry DevStats"|g' "$f"
  done
fi
cp -n ${GRAFANA_DATA}/public/img/grafana_icon.svg ${GRAFANA_DATA}/public/img/grafana_icon.svg.bak
cp grafana/img/xregistry.svg ${GRAFANA_DATA}/public/img/grafana_icon.svg || exit 1
cp -n ${GRAFANA_DATA}/public/img/grafana_com_auth_icon.svg ${GRAFANA_DATA}/public/img/grafana_com_auth_icon.svg.bak
cp grafana/img/xregistry.svg ${GRAFANA_DATA}/public/img/grafana_com_auth_icon.svg || exit 1
cp -n ${GRAFANA_DATA}/public/img/grafana_net_logo.svg ${GRAFANA_DATA}/public/img/grafana_net_logo.svg.bak
cp grafana/img/xregistry.svg ${GRAFANA_DATA}/public/img/grafana_net_logo.svg || exit 1
cp -n ${GRAFANA_DATA}/public/img/fav32.png ${GRAFANA_DATA}/public/img/fav32.png.bak
cp grafana/img/xregistry32.png ${GRAFANA_DATA}/public/img/fav32.png || exit 1
cp -n ${GRAFANA_DATA}/public/img/fav16.png ${GRAFANA_DATA}/public/img/fav16.png.bak
cp grafana/img/xregistry32.png ${GRAFANA_DATA}/public/img/fav16.png || exit 1
cp -n ${GRAFANA_DATA}/public/img/fav_dark_16.png ${GRAFANA_DATA}/public/img/fav_dark_16.png.bak
cp grafana/img/xregistry32.png ${GRAFANA_DATA}/public/img/fav_dark_16.png || exit 1
cp -n ${GRAFANA_DATA}/public/img/fav_dark_32.png ${GRAFANA_DATA}/public/img/fav_dark_32.png.bak
cp grafana/img/xregistry32.png ${GRAFANA_DATA}/public/img/fav_dark_32.png || exit 1
echo 'OK'
