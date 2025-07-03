#!/bin/bash
# DBDEBUG=1 - verbose operations
if [ -z "$1" ]
then
  echo "$0 you need to specify at least one argument"
  exit 1
fi
if [ -z "${STAGE}" ]
then
  STAGE=prod
fi
if [ -z "${N}" ]
then
  N=0
fi
cmd=${1}
shift
#quoted_args=$(printf '%q ' "$@")
#if [ ! -z "$DBDEBUG" ]
#then
#  echo "kubectl exec -itn 'devstats-${STAGE}' 'devstats-postgres-${N}' -- bash -c \"${cmd} ${quoted_args}\""
#fi
#kubectl exec -itn "devstats-${STAGE}" "devstats-postgres-${N}" -- bash -c "${cmd} ${quoted_args}"
if [ ! -z "$DBDEBUG" ]
then
  echo "'${cmd}' '${@}'" >&2
fi
# kubectl exec -itn "devstats-${STAGE}" "devstats-postgres-${N}" -- env VAR=VAL "${cmd}" "${@}"
kubectl exec -itn "devstats-${STAGE}" "devstats-postgres-${N}" -- "${cmd}" "${@}"
