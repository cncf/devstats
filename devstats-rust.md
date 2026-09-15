# DevStats: Go → Rust

[DevStats](https://github.com/cncf/devstats) backend ([devstatscode](https://github.com/cncf/devstatscode)) was rewritten from Go to Rust. All 23 programs and the shared library. It has been running in production since 2026-09-12.

## What

- 1:1 replacement: same binary names, command line options, environment variables, logs and database writes. Nothing else in DevStats (SQL metrics, Grafana, Helm charts, cron schedules) had to change - only the container images.
- Each program has a differential test suite: the Go and Rust binaries run on the same inputs (PostgreSQL databases, git repositories, GitHub API, GH Archive files) and their outputs are compared byte-for-byte. Over 1,000 such scenarios, plus unit tests. Both implementations are kept in sync for now, Go being the reference.
- The tests and the first production days surfaced about 60+ bugs in the Go code, plus a few in the new Rust code. All fixed, in both implementations. Top classes: panics on unexpected input (index out of range, nil map, division by zero), concurrency (data races, goroutine leaks, nondeterministic map-order output), PostgreSQL and time-zone semantics in the sync/restore passes (aborted transactions, zone-less timestamps, duplicate keys), silently ignored errors and wrong exit codes; the rest were input validation and log formatting.

## Performance

Measured on the production and test clusters: one median per program over every scheduled run of every project (except the aggregate `all` and `kubernetes`), ~140,000 runs, same features in both:

- Full project sync (`gha2db_sync`): 4m06s → 1m29s.
- GitHub API sync (`ghapi2db`): 3m02s → 20 s. Most of it is a rate-limit handling bug found during the port and fixed in both; on identical code Rust is 1.3× faster.
- GH Archive download and parse (`gha2db`): 21 s → 21 s - network-bound.
- PostgreSQL-bound steps (`structure`, `tags`, `columns`, `annotations`, `calc_metric`, `import_affs`): unchanged - the database is the limit, not the language.
- Binaries (stripped, static): 2.2× smaller in total, 126 MB → 58 MB for the 17 programs in the sync image, e.g. `gha2db_sync` 7.2 MB → 3.3 MB, `calc_metric` 7.1 MB → 3.0 MB. Container images: 210 MB → 139 MB (sync), 45 MB → 33 MB (API).
- Memory: no garbage collector, memory is freed deterministically. The Go version tuned the GC by hand (`SetGCPercent`, periodic `FreeOSMemory`, explicit `runtime.GC()`) - none of that exists in Rust.

## Why Rust

- No GC: predictable memory and latency.
- Ownership and exhaustive matching: nil dereferences, data races and unhandled cases are compile errors, not runtime panics.
- Smaller binaries and images.
- Same or better throughput on every step, big wins where the code is CPU or connection bound.

## Status

- Production: all CronJobs on both clusters run the Rust images (`-rust` suffix).
- Code: [devstatscode/rust](https://github.com/cncf/devstatscode/tree/master/rust).
