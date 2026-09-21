-- Add repository groups
with repo_latest as (
  select sub.repo_id,
    sub.repo_name
  from (
    select repo_id,
      dup_repo_name as repo_name,
      row_number() over (partition by repo_id order by created_at desc, id desc) as row_num
    from
      gha_events
  ) sub
  where
    sub.row_num = 1
)
update
  gha_repos r
set
  alias = (
    select rl.repo_name
    from
      repo_latest rl
    where
      rl.repo_id = r.id
  )
where
  r.name like '%_/_%'
  and r.name not like '%/%/%'
;

-- Maybe some new repos specified in CTE config appeared, so their config will be changed
-- And because we only want to assign not specified to 'Other' - we do this configuration again
delete from gha_repo_groups;

-- Per each SIG that has claimed ownership via one of it's subprojects we add a new entry in gha_repo_groups
-- 'repos' CTE is a full mapping between repo name N:M repo group
-- each line is ('repo/name', 'Repo Group Name'),
with repos as (
  select
    repo,
    repo_group
  from (
    values
      -- compute
      ('kubevirt/ansible-kubevirt-modules', 'compute'),
      ('kubevirt/cloud-image-builder', 'compute'),
      ('kubevirt/cluster-api-provider-external', 'compute'),
      ('kubevirt/cluster-network-addons-operator', 'compute'),
      ('kubevirt/common-templates', 'compute'),
      ('kubevirt/community', 'compute'),
      ('kubevirt/cpu-nfd-plugin', 'compute'),
      ('kubevirt/csi-driver', 'compute'),
      ('kubevirt/external-storage', 'compute'),
      ('kubevirt/hostpath-provisioner', 'compute'),
      ('kubevirt/hyperconverged-cluster-operator', 'compute'),
      ('kubevirt/katacoda-scenarios', 'compute'),
      ('kubevirt/krew-index', 'compute'),
      ('kubevirt/kubectl-virt-plugin', 'compute'),
      ('kubevirt/kubevirt', 'compute'),
      ('kubevirt/kubevirt-ssp-operator', 'compute'),
      ('kubevirt/kubevirt-tekton-tasks', 'compute'),
      ('kubevirt/kubevirt-template-validator', 'compute'),
      ('kubevirt/libvirt', 'compute'),
      ('kubevirt/machine-remediation', 'compute'),
      ('kubevirt/must-gather', 'compute'),
      ('kubevirt/node-labeller', 'compute'),
      ('kubevirt/node-maintenance-operator', 'compute'),
      ('kubevirt/ssp-operator', 'compute'),
      -- documentation
      ('kubevirt/demo', 'documentation'),
      ('kubevirt/kubevirt-tutorial', 'documentation'),
      ('kubevirt/kubevirt.github.io', 'documentation'),
      ('kubevirt/user-guide', 'documentation'),
      -- storage
      ('kubevirt/containerized-data-importer', 'storage'),
      -- testing
      ('kubevirt/kubevirtci', 'testing'),
      ('kubevirt/project-infra', 'testing'),
      -- network
      ('k8snetworkplumbingwg/kubemacpool', 'network'),
      ('k8snetworkplumbingwg/multus-dynamic-networks-controller', 'network'),
      ('kubevirt/cluster-network-addons-operator', 'network'),
      ('kubevirt/ipam-extensions', 'network'),
      ('kubevirt/kubevirt', 'network'),
      ('kubevirt/macvtap-cni', 'network'),
      ('kubevirt/user-guide', 'network'),
      -- KubeVirt Perf and Scale SIG
      ('kubevirt/kubevirt', 'KubeVirt Perf and Scale SIG'),
      -- observability
      ('kubevirt/cluster-network-addons-operator', 'observability'),
      ('kubevirt/containerized-data-importer', 'observability'),
      ('kubevirt/hostpath-provisioner', 'observability'),
      ('kubevirt/hostpath-provisioner-operator', 'observability'),
      ('kubevirt/hyperconverged-cluster-operator', 'observability'),
      ('kubevirt/kubevirt', 'observability'),
      ('kubevirt/monitoring', 'observability'),
      ('kubevirt/must-gather', 'observability'),
      ('kubevirt/ssp-operator', 'observability'),
      -- KubeVirt Buildsystem SIG
      ('kubevirt/containerized-data-importer', 'KubeVirt Buildsystem SIG'),
      ('kubevirt/kubevirt', 'KubeVirt Buildsystem SIG'),
      ('kubevirt/kubevirtci', 'KubeVirt Buildsystem SIG'),
      -- KubeVirt CI Operations Group
      ('kubevirt/project-infra', 'KubeVirt CI Operations Group')
  ) AS a (repo, repo_group)
)
insert into gha_repo_groups(id, name, alias, repo_group, org_id, org_login)
select
  r.id, r.name, r.alias, c.repo_group, r.org_id, r.org_login
from
  gha_repos r,
  repos c
where
  r.name = c.repo
;

-- To see missing repos
/*
select
  c.repo
from
  repos c
left join
  gha_repos r
on
  r.name = c.repo
where
  r.name is null;
;
*/


-- Remaining repos that were not assigned to at least 1 repo group fall back to 'Other' repo group
insert into gha_repo_groups(id, name, alias, repo_group, org_id, org_login)
select
  r.id, r.name, r.alias, 'Other', r.org_id, r.org_login
from
  gha_repos r
left join
  gha_repo_groups rg
on
  r.name = rg.name
where
  rg.name is null
;

select
  repo_group,
  count(*) as number_of_repos
from
  gha_repo_groups
where
  repo_group is not null
group by
  repo_group
order by
  number_of_repos desc,
  repo_group asc;