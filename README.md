# GitLab Runner Module (Dockerized)

A dockerized GitLab Runner that runs the jobs with the [Docker Executor](https://docs.gitlab.com/runner/executors/docker.html).

WARNING: BETA STATUS!

## Features

This module handles properly and without side effects:

* Any change in configuration will be reflected to the appropriate resources and by the way handled properly
* The runner is registered once at creation time (you can taint the module's resource `gitlab_runer.runner` to force re-registration)
* The runner is unregistered at destruction time (ensuring proper cleanup, your GitLab's administrators will thank you for this)
* The authentication token is not hardcoded in the `config.toml` but exposed as an environment variable

## What's Next

We will have to work on the following topics (not in any particular order):

* Add more document (behavior, directories, limitations)
* Add some examples with multiple runners with/without "count"
* Manage more [configuration parameters](https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runners-section)
* [Next GitLab Runner Token Architecture](https://docs.gitlab.com/ee/architecture/blueprints/runner_tokens/)

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

variable "remote_ssh_host" {
  type = string
}

variable "remote_ssh_port" {
  type    = number
  default = 22
}

variable "remote_ssh_user" {
  type = string
}

locals {
  gitlab_server_url = "https://gitlab.example.com"
}

provider "docker" {
  host     = "ssh://${var.remote_ssh_user}@${var.remote_ssh_host}:${var.remote_ssh_port}"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]

  registry_auth {
    address = "registry.fisch3r.net"
  }
}

provider "gitlab" {
  base_url = local.gitlab_server_url
}

provider "system" {
  ssh {
    host        = var.remote_ssh_host
    port        = var.remote_ssh_port
    user        = var.remote_ssh_user
    private_key = file("~/.ssh/id_rsa")
  }
  sudo = true
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

  server_url         = local.gitlab_server_url
  server_ca_cert     = null # Optional, e.g. file("my-server-ca.crt")
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
├── config
│   ├── certs
│   └── config.toml
└── scripts
    ├── check-live
    └── entrypoint

5 directories, 4 files
```
