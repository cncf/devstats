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
      -- sig-compute
      ('kubevirt/ansible-kubevirt-modules', 'sig-compute'),
      ('kubevirt/cloud-image-builder', 'sig-compute'),
      ('kubevirt/cluster-api-provider-external', 'sig-compute'),
      ('kubevirt/cluster-network-addons-operator', 'sig-compute'),
      ('kubevirt/common-templates', 'sig-compute'),
      ('kubevirt/community', 'sig-compute'),
      ('kubevirt/cpu-nfd-plugin', 'sig-compute'),
      ('kubevirt/csi-driver', 'sig-compute'),
      ('kubevirt/external-storage', 'sig-compute'),
      ('kubevirt/hostpath-provisioner', 'sig-compute'),
      ('kubevirt/hyperconverged-cluster-operator', 'sig-compute'),
      ('kubevirt/katacoda-scenarios', 'sig-compute'),
      ('kubevirt/krew-index', 'sig-compute'),
      ('kubevirt/kubectl-virt-plugin', 'sig-compute'),
      ('kubevirt/kubevirt', 'sig-compute'),
      ('kubevirt/kubevirt-ssp-operator', 'sig-compute'),
      ('kubevirt/kubevirt-tekton-tasks', 'sig-compute'),
      ('kubevirt/kubevirt-template-validator', 'sig-compute'),
      ('kubevirt/kvm-info-nfd-plugin', 'sig-compute'),
      ('kubevirt/libvirt', 'sig-compute'),
      ('kubevirt/machine-remediation', 'sig-compute'),
      ('kubevirt/macvtap-cni', 'sig-compute'),
      ('kubevirt/must-gather', 'sig-compute'),
      ('kubevirt/node-labeller', 'sig-compute'),
      ('kubevirt/node-maintenance-operator', 'sig-compute'),
      ('kubevirt/ovs-cni', 'sig-compute'),
      ('kubevirt/ssp-operator', 'sig-compute'),
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
      ('containernetworking/plugins', 'network'),
      ('k8snetworkplumbingwg/kubemacpool', 'network'),
      ('k8snetworkplumbingwg/ovs-cni', 'network'),
      ('k8snetworkplumbingwg/sriov-network-operator', 'network'),
      ('nmstate/kubernetes-nmstate', 'network'),
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
      ('kubevirt/kubevirt', 'KubeVirt Buildsystem SIG')
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