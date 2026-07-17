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
