# GitLab Runner Terraform Module (Dockerized)

Manage a GitLab Runner using the
[Docker Executor](https://docs.gitlab.com/runner/executors/docker.html).

> **Limitation:** Multi-runner examples is not yet supported or documented.

* Registers the runner once at creation time (taint `gitlab_user_runner.self` to force re-registration)
* Unregisters the runner at destruction time (clean GitLab state)
* Keeps the authentication token out of the container's environment and of the rendered
  `config.toml`: the entrypoint reads it from a file readable by its owner alone (`0600`, owned by
  whoever runs Terraform)
* Any configuration change is reflected to the appropriate resources automatically


## Usage

See [examples/default](examples/default) for a complete working configuration.

```hcl
provider "gitlab" {
  base_url = "https://gitlab.example.com"
}

data "gitlab_group" "example" {
  full_path = "example"
}

resource "docker_image" "runner" {
  name = "gitlab/gitlab-runner:latest"
}

module "runner" {
  source = "git::https://github.com/davidfischer-ch/terraform-module-dockerized-gitlab-runner.git?ref=2.3.1"

  identifier  = "my-runner"
  description = "Dockerized runner hosted on my computer for testing purposes"
  image_id    = docker_image.runner.image_id

  # Storage

  data_directory = "/data"

  # Registration

  server_url  = "https://gitlab.example.com"
  runner_type = "group"
  group_id    = data.gitlab_group.example.id

  # Global Settings

  concurrency = 4
  log_level   = "warn"

  # Jobs Core Settings

  jobs_protected = false
  jobs_tags      = ["for:test", "node:my-computer"]

  # Jobs Docker Executor Settings

  jobs_privileged = false
}
```


## Data layout

All persistent data lives under `data_directory`:

```
data_directory/
├── builds/
├── cache/
├── config/
│   ├── certs/
│   ├── config.toml
│   └── token
├── scripts/
│   ├── check-live
│   └── entrypoint
└── storage/
```


## Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `identifier` | `string` | — | Unique name for resources and runner (must match `^[a-z]+(-[a-z0-9]+)*$`). |
| `description` | `string` | — | Maintenance note. |
| `labels` | `map(string)` | — | Labels attached to the runner container. |
| `enabled` | `bool` | `true` | Start or stop the runner container. |
| `paused` | `bool` | `false` | Pause the runner (do not process jobs). |
| `env` | `map(string)` | `{}` | Environment variables for the runner (not the jobs). |
| `image_id` | `string` | — | [GitLab Runner](https://hub.docker.com/r/gitlab/gitlab-runner/tags) Docker image's ID. |
| `cpu_set` | `string` | `null` | CPUs the runner can use (e.g. `0-4`, `1,3`). |
| `cpu_shares` | `number` | `null` | CPU share ratio (e.g. `0.5`). |
| `memory` | `number` | `512` | Memory limit in MB (minimum 64). |
| `swap` | `number` | `128` | Swap limit in MB. |
| `hosts` | `map(string)` | `{}` | Extra `/etc/hosts` entries for the container. |
| `listener_address` | `string` | `"127.0.0.1"` | Address the published ports bind to. |
| `metrics_port` | `number` | `9252` | Host port for Prometheus metrics. |
| `data_directory` | `string` | — | Host path for persistent volumes. |
| `runner_type` | `string` | — | Runner scope: `instance`, `group`, or `project`. |
| `group_id` | `string` | `null` | Group ID (group runners only). |
| `project_id` | `string` | `null` | Project ID (project runners only). |
| `server_url` | `string` | — | GitLab server URL. |
| `server_ca_cert` | `string` | `null` | Custom CA certificate content (PEM). |
| `check_interval` | `number` | `3` | Interval between job checks in seconds. |
| `concurrency` | `number` | `10` | Max concurrent jobs across all runners on this host. |
| `log_format` | `string` | `"text"` | Log format (`runner`, `text`, `json`). |
| `log_level` | `string` | `"warn"` | Log level (`debug`, `info`, `warn`, `error`, `fatal`, `panic`). |
| `debug_enabled` | `bool` | `false` | Enable debugging mode. |
| `metrics_enabled` | `bool` | `false` | Enable Prometheus metrics exporter. |
| `jobs_concurrency` | `number` | `0` | Max concurrent jobs for this runner (0 = unlimited). |
| `jobs_env` | `map(string)` | `{}` | Environment variables injected into jobs. |
| `jobs_extra_hosts` | `map(string)` | `{}` | Extra hosts defined in the job container environment. |
| `jobs_locked` | `bool` | `true` | Lock runner to a specific group or project. |
| `jobs_output_limit` | `number` | `4096` | Max build log size in KB. |
| `jobs_protected` | `bool` | `true` | Only protected branches can trigger jobs. |
| `jobs_requests_concurrency` | `number` | `1` | Max concurrent job requests to GitLab. |
| `jobs_run_untagged` | `bool` | `false` | Run untagged jobs. |
| `jobs_tags` | `list(string)` | — | Runner tags for job dispatch. |
| `jobs_timeout` | `number` | `3600` | Job timeout in seconds, at least 600; an apply that destroys or replaces the runner waits up to this long, plus 60 seconds, for its running jobs. |
| `jobs_allowed_images` | `list(string)` | `["*/*:*"]` | Allowed image patterns. |
| `jobs_allowed_pull_policies` | `list(string)` | `["always", "if-not-present", "never"]` | Allowed pull policies. |
| `jobs_allowed_services` | `list(string)` | `["*/*:*"]` | Allowed service image patterns. |
| `jobs_pull_policy` | `list(string)` | `["always", "if-not-present"]` | Pull policies tried in order. |
| `jobs_privileged` | `bool` | `false` | Run job containers in privileged mode. |
| `jobs_volumes` | `list(string)` | `[]` | Additional volume mounts for jobs. |
| `jobs_cgroup_parent` | `string` | `null` | Parent cgroup of the job and service containers, a slice with Docker's systemd driver (e.g. `ci.slice`): they share its limits. |
| `jobs_cpu_shares` | `number` | `null` | CPU weight of each job container (Docker's default: 1024). |
| `jobs_cpus` | `number` | `null` | CPUs each job container can use (e.g. `1.5`). |
| `jobs_memory` | `number` | `null` | Memory limit of each job container in MB (minimum 64). |
| `jobs_memory_swap` | `number` | `null` | Memory plus swap limit of each job container in MB; equal to `jobs_memory`, no swap. |
| `jobs_services_cpu_shares` | `number` | `null` | CPU weight of each service container (Docker's default: 1024). |
| `jobs_services_cpus` | `number` | `null` | CPUs each service container can use. |
| `jobs_services_memory` | `number` | `null` | Memory limit of each service container in MB (minimum 64). |
| `jobs_services_memory_swap` | `number` | `null` | Memory plus swap limit of each service container in MB. |


## Requirements

* Terraform >= 1.17
* [kreuzwerker/docker](https://github.com/kreuzwerker/terraform-provider-docker) >= 4.7.0
* [gitlabhq/gitlab](https://github.com/gitlabhq/terraform-provider-gitlab) >= 16.8.1
* [hashicorp/local](https://github.com/hashicorp/terraform-provider-local) >= 2.4.1


## Tests

```bash
terraform init -backend=false
terraform test
```

`terraform test` needs Terraform >= 1.17, the module's own floor. The tests plan against mocked
providers: they assert what the module renders and passes to Docker (ports, env, healthcheck, the
storage command's text, the entrypoint), and run neither the entrypoint, the provisioner, the runner
nor the `verify` action. They run on every push, in the GitHub workflow (with the newest providers
and with their minimums) and in the GitLab pipeline.

`tests/e2e/run.sh` applies the module against a real Docker daemon and a stub of the GitLab API
(`tests/e2e/stub.py`), which registers the runner and answers its job requests with no job. It
checks the healthcheck, the token (in the `config.toml` the entrypoint writes, readable by its
owner alone, and absent from the container's environment) and the metrics listener on loopback,
runs `verify` on a valid and on a refused token, then destroys everything. The GitHub workflow and
the GitLab pipeline run it on GitLab Runner 19.5; locally:

```bash
E2E_IMAGE=gitlab/gitlab-runner:ubuntu-v19.5.2 sh tests/e2e/run.sh
```

The Docker daemon must see the data directory at the same path: set `E2E_DATA_DIRECTORY` to a
directory on a filesystem both share when Terraform runs in a container of its own. Terraform
reaches the stub on port 19080, published on loopback, or on the daemon's host under a TCP
`DOCKER_HOST`: set `E2E_STUB_ADDRESS` to another address of the daemon's host that Terraform
reaches. The runner publishes its metrics on port 19252.


## Actions

On-demand operations on the runner. Each runs only when invoked, never during an ordinary `apply`,
and leaves nothing in the state:

```bash
terraform apply -invoke='module.runner.action.docker_exec.<action>'
```

Replace `module.runner` with the module's address.

| Action | What it does | When |
|--------|--------------|------|
| `verify` | `gitlab-runner verify`: the registration checked against the GitLab server; fails unless the runner is reported valid | After a token rotation, or when jobs stay pending |


## References

* https://hub.docker.com/r/gitlab/gitlab-runner/tags
* https://docs.gitlab.com/runner/executors/docker.html
* https://docs.gitlab.com/runner/configuration/advanced-configuration.html
