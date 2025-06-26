[![Build Status](https://travis-ci.org/cncf/devstats.svg?branch=master)](https://travis-ci.org/cncf/devstats)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/1357/badge)](https://bestpractices.coreinfrastructure.org/projects/1357)

# GitHub archives and git Grafana visualization dashboards

Authors: Łukasz Gryglicki <lgryglicki@cncf.io>, Justyna Gryglicka <jgryglicka@cncf.io>.

This is a toolset to visualize GitHub [archives](https://www.gharchive.org) using Grafana dashboards.

GHA2DB stands for **G**it**H**ub **A**rchives to **D**ash**B**oards.

More information about Kubernetes dashboards [here](https://github.com/cncf/devstats/blob/master/README_K8s.md).


# Kubernetes and Helm

Please see [example Helm chart](https://github.com/cncf/devstats-helm-example) for an example Helm deployment.

Please see [Helm chart](https://github.com/cncf/devstats-helm) for a full Helm deployment.

Please see [LF Helm chart](https://github.com/cncf/devstats-helm-lf) for the LF Helm deployment (it is a data deployment, has no Grafana).

Please see [GraphQL Helm chart](https://github.com/cncf/devstats-helm-graphql) for GraphQL foundation DevStats deployment.

Please see [Kubernetes dashboard](https://github.com/cncf/devstats-kubernetes-dashboard) if you want to enable a local dashboard to explore the cluster state.

Please see [bare metal example](https://github.com/cncf/devstats-example) to see an example of bare metal deployment.

The rest of this document describes the current bare metal deployment on metal.equinix.com used by CNCF projects.


# Presentations

- Presentations are available [here](https://github.com/cncf/devstats/blob/master/docs/presentation).
- Direct [link](https://docs.google.com/presentation/d/1v5zuSFQkwcthWXgS2p9vs9x5e4fnavMR8HdykS7aWYA/edit?usp=sharing).
- Another direct [link](https://docs.google.com/presentation/d/1LLv4kio_KGP36cjkpeSMHZrNl0IYJ7B2pKGU0aHWqx8/edit?usp=sharing).


# Talks

- [Who What How: Understanding Kubernetes Development through DevStats](https://www.youtube.com/watch?v=D3CMuxQymR8).
- [A Kubernetes Application End-to-End: DevStats](https://www.youtube.com/watch?v=U2PTifzzKNE&t=58s).


# Architecture

DevStats is deployed using [Helm](https://helm.sh) on [Kubernetes](https://kubernetes.io) running on bare metal servers provided by [Equinix](https://www.equinix.com).

DevStats is written in [Go](https://go.dev), it uses [GitHub archives](https://www.gharchive.org), [GitHub API](https://docs.github.com/en/rest) and [git](https://git-scm.com) as its main data sources.

Under the hood, DevStats uses the following CNCF projects:
- Helm (for deployment).
- containerd (as a Kubernetes container runtime, CRI).
- cert-manager (for HTTPS/SSL certificates).
- OpenEBS (for local storage volumes support).
- MetalLB (as a load balancer for bare metal servers).
- CoreDNS (Kubernetes internal DNS).

And other projects, including:
- Equinix (bare metal servers provider).
- Ubuntu (containers base operating system).
- kubeadm (for installing Kubernetes).
- NFS (for shared write network volumes support).
- NGINX (for ingress).
- Calico (as networking for Kubernetes, CNI).
- Golang (DevStats is written in Go).
- PostgreSQL (DevStats database is Postgres).
- patroni (HA deployment of PostgreSQL database, tweaked for DevStats).
- GitHub archives (main data source).
- GitHub API (data source).
- git (data source).
- Grafana (UI).
- Let's Encrypt (provides HTTPS/SSL certificates).
- Travis CI (continuous integration & testing).

Please check [this](https://github.com/cncf/devstats-helm#architecture) for a detailed architecture description.


# Deploying on your own project(s)

See the simple [DevStats example](https://github.com/cncf/devstats-example) repository for single project deployment (Homebrew), follow [instructions](https://github.com/cncf/devstats-example/blob/master/SETUP_OTHER_PROJECT.md) to deploy for your own project.

# Goal

We want to create a toolset for visualizing various metrics for the Kubernetes community (and also for all CNCF projects).

Everything is open source so that it can be used by other CNCF and non-CNCF open source projects.

The only requirement is that project must be hosted on a public GitHub repository/repositories.

# Data hiding

If you want to hide your data (replace with anon-#) please follow the instructions [here](https://github.com/cncf/devstats/blob/master/HIDE_DATA.md).

# Forking and installing locally

This toolset uses only Open Source tools: GitHub archives, GitHub API, git, Postgres databases, and multiple Grafana instances.
It is written in Go and can be forked and installed by anyone.

Contributions and PRs are welcome.
If you see a bug or want to add a new metric please create an [issue](https://github.com/cncf/devstats/issues) and/or [PR](https://github.com/cncf/devstats/pulls).

To work on this project locally please fork the original [repository](https://github.com/cncf/devstats), and:
- [Compiling and running on Linux Ubuntu 18 LTS](./INSTALL_UBUNTU18.md).
- [Compiling and running on Linux Ubuntu 17](./INSTALL_UBUNTU17.md).
- [Compiling and running on Linux Ubuntu 16 LTS](./INSTALL_UBUNTU16.md).
- [Compiling and running on macOS](./INSTALL_MAC.md).
- [Compiling and running on FreeBSD](./INSTALL_FREEBSD.md).

Please see [Development](https://github.com/cncf/devstats/blob/master/DEVELOPMENT.md) for local development guide.

For more detailed description of all environment variables, tools, switches, etc, please see [Usage](https://github.com/cncf/devstats/blob/master/USAGE.md).

# Metrics

We want to support all kinds of metrics, including historical ones.
Please see [requested metrics](https://docs.google.com/document/d/1o5ncrY6lVX3qSNJGWtJXx2aAC2MEqSjnML4VJDrNpmE/edit?usp=sharing) to see what kind of metrics are needed.
Many of them cannot be computed based on the data sources currently used.

# Repository groups

There are some groups of repositories that are grouped together as a repository groups.
They are defined in [scripts/kubernetes/repo_groups.sql](https://github.com/cncf/devstats/blob/master/scripts/kubernetes/repo_groups.sql).

To setup default repository groups:
- `PG_PASS=pwd ./kubernetes/setup_repo_groups.sh`.

This is a part of `kubernetes/psql.sh` script and [kubernetes psql dump](https://devstats.cncf.io/backups/gha.dump) already has groups configured.

In an [All CNCF project](https://all.teststats.cncf.io) repository groups are mapped to individual CNCF projects [scripts/all/repo_groups.sql](https://github.com/cncf/devstats/blob/master/scripts/all/repo_groups.sql):

# Company Affiliations

We also want to have per company statistics. To implement such metrics we need a mapping of developers and their employers.

There is a project that attempts to create such mapping [cncf/gitdm](https://github.com/cncf/gitdm).

DevStats has an import tool that fetches company affiliations from `cncf/gitdm` and allows to create per company metrics/statistics. It also uses `companies.yaml` file to map company acquisitions (any data generated by a company acquired by another company is assigned to the latter using a mapping from `companies.yaml`).

If you see errors in the company affiliations, please open a pull request on [cncf/gitdm](https://github.com/cncf/gitdm) and the updates will be reflected on [https://k8s.devstats.cncf.io](https://k8s.devstats.cncf.io) a couple of days after the PR has been accepted. Note that gitdm supports mapping based on dates, to account for developers moving between companies.

New affiliations are imported into DevStats about 1-2 times/month.

# Architecture

For architecture details please see [architecture](https://github.com/cncf/devstats/blob/master/ARCHITECTURE.md) file.

Detailed usage is [here](https://github.com/cncf/devstats/blob/master/USAGE.md)

# Adding new metrics

Please see [metrics](https://github.com/cncf/devstats/blob/master/METRICS.md) to see how to add new metrics.

# Adding new projects

To add a new project on a bare metal deployment follow [adding new project](https://github.com/cncf/devstats/blob/master/ADDING_NEW_PROJECT.md) instructions.

See `cncf/devstats-helm`:`ADDING_NEW_PROJECTS.md` for information about how to add more projects on Kubernetes/Helm deployment.

# Grafana dashboards

Please see [dashboards](https://github.com/cncf/devstats/blob/master/DASHBOARDS.md) to see a list of already defined Grafana dashboards.

# Exporting data

Please see [exporting](https://github.com/cncf/devstats/blob/master/EXPORT.md).

# Detailed Usage instructions

- [USAGE](https://github.com/cncf/devstats/blob/master/USAGE.md)

# Servers

The servers to run `devstats` are generously provided by [Equinix](https://metal.equinix.com) bare metal hosting as part of CNCF's [Community Infrastructure Lab](https://github.com/cncf/cluster).

# One line run all projects

- Use `GHA2DB_PROJECTS_OVERRIDE="+cncf" PG_PASS=pwd devstats`.
- Or add this command using `crontab -e` to run every hour HH:08.

# Checking projects activity

- Use: `PG_PASS=... PG_DB=allprj ./devel/activity.sh '1 month,,' > all.txt`.
- Example results [here](https://teststats.cncf.io) - all CNCF project activity during January 2018, excluding bots.


# Project moving to a new GitHub organization

Please check `NEW_ORG.md`.


# Troubleshooting

If you see error like this `pq: row is too big: size 8192, maximum size 8160` and/or `Error result for xyz (took 11m52.048191357s)`:

- Shell into logging database and check:
- Run on DevStats node: `k exec -itn devstats-prod devstats-postgres-0 -- psql devstats`.
- Run while on `devstats` database: `select dt, run_dt, msg from gha_logs where msg like '%Error result for%' order by run_dt desc;`.
```
             dt             |           run_dt           |                                  msg
----------------------------+----------------------------+-----------------------------------------------------------------------
 2024-09-01 00:48:07.079436 | 2024-09-01 00:34:26.426402 | Error result for helm (took 13m36.712884455s): exit status 2
 2024-09-07 00:16:11.132541 | 2024-09-07 00:04:14.051939 | Error result for prometheus (took 11m52.048191357s): exit status 2
 2024-09-07 00:26:43.701404 | 2024-09-07 00:05:55.08925  | Error result for fluentd (took 15m1.328366817s): exit status 2
 2024-09-07 00:16:11.038887 | 2024-09-07 00:08:43.846938 | Error result for grpc (took 7m24.348182232s): exit status 2
 2024-09-03 13:20:02.682134 | 2024-09-03 12:57:23.220227 | Error result for opentelemetry (took 22m29.324614973s): exit status 2
 2024-09-03 13:09:56.535074 | 2024-09-03 13:04:43.451026 | Error result for spinnaker (took 5m7.631109092s): exit status 2
(6 rows)
```
- You can investigate each via: `` echo "select dt, prog, proj, msg from gha_logs where run_dt = '2024-09-01 00:34:26.426402';" | k exec -in devstats-prod devstats-postgres-1 -- psql devstats > log.txt ``.
- Or: `` select distinct proj from gha_logs where msg like '%row is too big%'; ``.
- Eventually check: `` vim logs_prod.txt logs_test.txt ``.
- `row is too big` is usually caused by metric: `suser_activity`. You can add this metric to `./devel/test_metrics.yaml` and generate devstats docker images to reinitialize it for given project(s) via:
- `helm install --generate-name ./devstats-helm --set namespace='devstats-prod',skipSecrets=1,skipPVs=1,skipBackupsPV=1,skipVacuum=1,skipBackups=1,skipBootstrap=1,skipCrons=1,skipAffiliations=1,skipGrafanas=1,skipServices=1,skipPostgres=1,skipIngress=1,skipStatic=1,skipAPI=1,skipNamespaces=1,testServer='',prodServer='1',provisionImage='lukaszgryglicki/devstats-prod',provisionCommand='./devstats-helm/add_metric.sh',nCPUs=8,indexProvisionsFrom=N,indexProvisionsTo=M`.


# TSDB tables - utils

- To vacuum all tables do: `` [N=2] [TEST=1] ./util_sh/vacuum_tsdb_tables_all.sh `` - eventually check which node is a master via: `` k exec -n devstats-env devstats-postgres-0 -- patronictl list ``.
- To recreate all tables (needed to drop hidden unused columns) do: `` [N=2] [TEST=1] ./util_sh/recreate_tsdb_tables_all.sh ``.
- To add permissions for all tables do: `` [N=2] [TEST=1] ./util_sh/permissions_tsdb_tables_all.sh ``.
