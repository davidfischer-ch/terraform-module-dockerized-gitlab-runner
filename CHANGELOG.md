# Changelog


## Release v2.3.1 (2026-11-20)

Diff: https://github.com/davidfischer-ch/terraform-module-dockerized-gitlab-runner/compare/2.3.0...2.3.1

### Features

CI:

* Add an end-to-end test of the module and its `verify` action against a real Docker daemon and a stub of the GitLab API, on GitLab Runner 19.5

### Fix and enhancements

Runner:

* Refuse a `jobs_timeout` below 600 seconds, GitLab's minimum, at validation instead of a provider error at plan

CI:

* Test at both ends of `versions.tf`, every version read from it at run time: the newest Terraform and providers, and their floors

Docs:

* Fix the README's taint address (`gitlab_user_runner.self`) and its data layout


## Release v2.3.0 (2026-11-19)

Diff: https://github.com/davidfischer-ch/terraform-module-dockerized-gitlab-runner/compare/2.2.0...2.3.0

### Minor compatibility breaks

Runner:

* Publish the metrics on `127.0.0.1` by default, any address through the new `listener_address` input
    * A Prometheus scraping the runner from another host needs `listener_address` set

### Features

Actions:

* Add a `verify` action, failing unless the GitLab server reports the runner valid

CI:

* Add CI: formatting, validation and the tests, in the GitHub workflow (with the newest providers and their minimums) and in the GitLab pipeline

### Fix and enhancements

Runner:

* Keep the runner token out of the container's environment, in a `0600` file the entrypoint reads
    * The container is replaced once on upgrade
* Run the healthcheck, its test given in the exec form Docker expects
* Give a stopping runner `jobs_timeout` to finish its jobs
    * An apply that destroys or replaces the runner waits up to `jobs_timeout` plus 60 seconds
* Quote the storage path of the `chmod` provisioner

Requirements:

* Require Terraform 1.17
* Require the Docker provider 4.7.0

Docs:

* Point the README and the examples at this release


## Release v2.2.0 (2026-11-17)

### Features

* Add `jobs_cgroup_parent`, the parent cgroup of the job and service containers, which then share
  its limits (a systemd slice with Docker's systemd cgroup driver)
* Add per-container memory, swap and CPU limits for the jobs (`jobs_memory`, `jobs_memory_swap`,
  `jobs_cpus`, `jobs_cpu_shares`) and their services (`jobs_services_*`), all unset by default

## Release v2.1.1 (2026-03-14)

### Fix and enhancements

* Reorder variables to be consistent

## Release v2.1.0 (2026-03-13)

### Minor compatibility breaks

* Change `log_level` default from `"info"` to `"warn"`

### Fix and enhancements

* Set `enabled` default to `true`, `paused` default to `false`
* Rewrite README to match module conventions
* Refine variable descriptions, validators, and attribute ordering
* Remove redundant default values from examples

## Release v2.0.1 (2026-03-13)

### Fix and enhancements

* Drop commented-out dead code (old registration token resource)
* Add examples

## Release v2.0.0 (2025-05-21)

### Major compatibility breaks

* Drop old registration workflow (registration token)

### Minor compatibility breaks

* Drop `registration_url` and `registration_token` variables
  * Replaced by `runner_type` variable and optional (`group_id`, `project_id`)

### Features

* Implement the new registration workflow (authentication token)

### Fix and enhancements

* Prevent infinite recreate by declaring `network_mode` to `bridge`

## Release v1.0.0 (2025-01-20)

Initial release
