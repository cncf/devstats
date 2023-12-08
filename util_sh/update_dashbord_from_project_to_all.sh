#!/bin/bash
# ONLY='project1 project2 ... projectN'
# REPLACE_ON='+grep-expr'|'-grep-expr'|'' (replace on destination matching grep expr (+), not-matching(-), unconditionally '')
if ( [ -z "${1}" ] || [ -z "${2}" ] )
then
  echo "${0}: usage: ${0}project-name dashboard-name.json"
  exit 1
fi
src="grafana/dashboards/${1}/${2}"
if [ ! -f "${src}" ]
then
  echo "dashboard ${src} doesn not exists, exiting"
  exit 2
fi
if [ ! -z "${REPLACE_ON}" ]
then
  mode="${REPLACE_ON:0:1}"
  if ( [ ! "${mode}" = "+" ] && [ ! "${mode}" = "-" ] )
  then
    echo "$0: mode must be either '-' or '+' in '${REPLACE_ON}'"
    exit 3
  fi
fi
. ./devel/project_names.sh || exit 4
srcName="${project_names[${1}]}"
if [ -z "$srcName" ]
then
  echo "$0: cannot fine name for ${1} project,e xisting"
  exit 5
fi
. ./devel/all_projs.sh || exit 6
for f in $all
do
  if [ "${f}" = "${1}" ]
  then
    echo "skipping source project ${1}"
    continue
  fi
  dst="grafana/dashboards/${f}/${2}"
  if [ ! -f "${dst}" ]
  then
    echo "dashboard ${dst} does not exist, skipping"
    continue
  fi
  if [ ! -z "${REPLACE_ON}" ]
  then
    mode="${REPLACE_ON:0:1}"
    if [ "${mode}" = "+" ]
    then
      hit=$(grep -l "${REPLACE_ON:1}" "$dst")
    elif [ "${mode}" = "-" ]
    then
      hit=$(grep -L "${REPLACE_ON:1}" "$dst")
    fi
    if [ -z "${hit}" ]
    then
      continue
    fi
    # echo "$f ${mode}hit: ${hit}"
  fi
  # name=$(cat projects.yaml | yq ".projects.${1}.name")
  name="${project_names[${f}]}"
  if [ -z "${name}" ]
  then
    echo "cannot fine name for ${f} project, defaulting to key name"
  fi
  # echo "cp ${src} ${dst}"
  cp "${src}" "${dst}"
  # MODE=ss0 FROM="    \"${1}\"" TO="    \"${f}\"" replacer "${dst}"
  MODE=ss0 FROM="\"${1}\"" TO="\"${f}\"" replacer "${dst}"
  MODE=ss0 FROM="\"${srcName}\"" TO="\"${name}\"" replacer "${dst}"
done
echo 'done.'
