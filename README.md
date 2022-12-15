# GitLab Runner Module (Dockerized)

A dockerized GitLab Runner that runs the jobs with the [Docker Executor](https://docs.gitlab.com/runner/executors/docker.html).

WARNING: ALPHA STATUS!

See the [TODO.md](TODO.md).

## Example

```
terraform {
  required_version = ">= 1.3"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.23.0"
    }

    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "3.20.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

provider "gitlab" {
  base_url = local.gitlab_server_url
}

locals {
  gitlab_server_url = "https://gitlab.example.com"
}

data "gitlab_group" "example" {
  full_path = "example"
}

resource "docker_image" "runner" {
  name = "gitlab/gitlab-runner:latest"
}

module "runner" {

  source = "git@github.com:davidfischer-ch/terraform-module-dockerized-gitlab-runner.git?ref=main"

  identifier  = "my-runner"
  description = "Dockerized runner hosted on my computer for testing purposes"

  labels = {}

  enabled  = true
  paused   = false
  image_id = docker_image.runner.image_id

  data_directory = "/data"

  # Registration

  gitlab_server_url  = local.gitlab_server_url
  registration_url   = data.gitlab_group.example.web_url
  registration_token = data.gitlab_group.example.runners_token

  # Global Settings

  concurrency   = 4
  log_format    = "text"
  log_level     = "info"
  debug_enabled = false

  # Jobs Core Settings

  jobs_protected = false

  jobs_tags = [
    "for:test",
    "node:my-computer",
    "host:restricted-container",
    "other:yesman"
  ]

  # Jobs Docker Executor Settings

  jobs_privileged = false
}
```

Data directory will contain something like this:

```
/data/my-runner/
├── builds
├── cache
├── certificates
├── config
│   ├── certs
│   └── config.toml
└── scripts
    ├── check-live
    ├── cleanup
    ├── config.toml
    └── entrypoint

6 directories, 5 files
```
