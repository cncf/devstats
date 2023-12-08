#!/bin/bash
. ./devel/all_projs.sh || exit 3
> ./devel/project_names.sh
chmod +x ./devel/project_names.sh
echo "declare -A project_names" >> ./devel/project_names.sh
for f in $all
do
  name=$(cat projects.yaml | yq ".projects.${f}.name")
  if ( [ -z "${name}" ] || [ "${name}" = "null" ] )
  then
    echo "cannot fine name for ${f} project, skipping"
    continue
  fi
  echo "mapping ${f} -> ${name}"
  echo "project_names[\"${f}\"]=\"${name}\"" >> ./devel/project_names.sh
done
echo 'done.'
. ./devel/project_names.sh
echo echo ${project_names[@]}
