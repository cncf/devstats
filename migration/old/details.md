Old step 3 part:
- While all CJs remain suspended, upgrade every release owning `type=cron`/`affiliations-cron` CJs, preserving its values, with (this is what update_cjs just did:
```
affiliationsDB=affiliations
checkImportedSHA=''
affiliationsGetAffsFiles=''
skipAffiliationsImport=1
# affsFdwUsePassword=1  # password mode only
```
- Do not include the dedicated affs-import release. Helm upgrades replace the per-project `patch_project_cronjobs` step persistently.
- Verify CJ envs, then restore previous states and explicitly enable the importer:
```
while IFS=$'\t' read -r cj old; do
  kubectl --context "$KUBE_CONTEXT" -n "$NS" patch "cronjob/$cj" --type merge -p "{\"spec\":{\"suspend\":$old}}" || exit 1
done < "$SUSPEND_STATE"
kubectl --context "$KUBE_CONTEXT" -n "$NS" patch cronjob/devstats-affiliations-import --type merge -p '{"spec":{"suspend":false}}'
```
