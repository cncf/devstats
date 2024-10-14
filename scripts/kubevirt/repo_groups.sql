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
update gha_repos set repo_group = alias;

insert into gha_repo_groups(id, name, alias, repo_group, org_id, org_login) select id, name, alias, coalesce(repo_group, name), org_id, org_login from gha_repos on conflict do nothing;
insert into gha_repo_groups(id, name, alias, repo_group, org_id, org_login) select id, name, alias, org_login, org_id, org_login from gha_repos where org_id is not null and org_login is not null and trim(org_login) != '' on conflict do nothing;


-- Per each SIG that has claimed ownership via one of it's subprojects we add a new entry in gha_repo_groups

insert into gha_repo_groups(id, name, repo_group, alias, org_id, org_login)
select id, name, 'sig-compute', alias, org_id, org_login
  from gha_repo_groups
 where lower(name) in (
          'kubevirt/ansible-kubevirt-modules',
          'kubevirt/cloud-image-builder',
          'kubevirt/cluster-api-provider-external',
          'kubevirt/cluster-network-addons-operator',
          'kubevirt/common-templates',
          'kubevirt/community',
          'kubevirt/cpu-nfd-plugin',
          'kubevirt/csi-driver',
          'kubevirt/external-storage',
          'kubevirt/hostpath-provisioner',
          'kubevirt/hyperconverged-cluster-operator',
          'kubevirt/katacoda-scenarios',
          'kubevirt/krew-index',
          'kubevirt/kubectl-virt-plugin',
          'kubevirt/kubevirt',
          'kubevirt/kubevirt-ssp-operator',
          'kubevirt/kubevirt-tekton-tasks',
          'kubevirt/kubevirt-template-validator',
          'kubevirt/kvm-info-nfd-plugin',
          'kubevirt/libvirt',
          'kubevirt/machine-remediation',
          'kubevirt/macvtap-cni',
          'kubevirt/must-gather',
          'kubevirt/node-labeller',
          'kubevirt/node-maintenance-operator',
          'kubevirt/ovs-cni',
          'kubevirt/ssp-operator',
       )
  on conflict update;

insert into gha_repo_groups(id, name, repo_group, alias, org_id, org_login)
select id, name, 'documentation', alias, org_id, org_login
  from gha_repo_groups
 where lower(name) in (
          'kubevirt/demo',
          'kubevirt/kubevirt-tutorial',
          'kubevirt/kubevirt.github.io',
          'kubevirt/user-guide',
       )
  on conflict update;

insert into gha_repo_groups(id, name, repo_group, alias, org_id, org_login)
select id, name, 'storage', alias, org_id, org_login
  from gha_repo_groups
 where lower(name) in (
          'kubevirt/containerized-data-importer',
       )
  on conflict update;

insert into gha_repo_groups(id, name, repo_group, alias, org_id, org_login)
select id, name, 'testing', alias, org_id, org_login
  from gha_repo_groups
 where lower(name) in (
          'kubevirt/kubevirtci',
          'kubevirt/project-infra',
       )
  on conflict update;

insert into gha_repo_groups(id, name, repo_group, alias, org_id, org_login)
select id, name, 'network', alias, org_id, org_login
  from gha_repo_groups
 where lower(name) in (
          'k8snetworkplumbingwg/kubemacpool',
          'k8snetworkplumbingwg/multi-networkpolicy-iptables',
          'k8snetworkplumbingwg/sriov-network-operator',
          'nmstate/kubernetes-nmstate',
       )
  on conflict update;

insert into gha_repo_groups(id, name, repo_group, alias, org_id, org_login)
select id, name, 'KubeVirt Perf and Scale SIG', alias, org_id, org_login
  from gha_repo_groups
 where lower(name) in (
          'kubevirt/kubevirt',
       )
  on conflict update;

insert into gha_repo_groups(id, name, repo_group, alias, org_id, org_login)
select id, name, 'observability', alias, org_id, org_login
  from gha_repo_groups
 where lower(name) in (
          'kubevirt/cluster-network-addons-operator',
          'kubevirt/containerized-data-importer',
          'kubevirt/hostpath-provisioner',
          'kubevirt/hostpath-provisioner-operator',
          'kubevirt/hyperconverged-cluster-operator',
          'kubevirt/kubevirt',
          'kubevirt/monitoring',
          'kubevirt/must-gather',
          'kubevirt/ssp-operator',
       )
  on conflict update;

insert into gha_repo_groups(id, name, repo_group, alias, org_id, org_login)
select id, name, 'KubeVirt Buildsystem SIG', alias, org_id, org_login
  from gha_repo_groups
 where lower(name) in (
          'kubevirt/kubevirt',
       )
  on conflict update;


-- for the remaining rows where the repo_group has not been touched we set the default "Other"

UPDATE gha_repos
SET repo_group = 'Other'
WHERE repo_group = alias


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