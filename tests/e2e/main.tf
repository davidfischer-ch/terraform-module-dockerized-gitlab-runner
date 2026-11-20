# The module against a real Docker daemon and a stub of the GitLab API, driven by run.sh.
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 4.7.0"
    }

    gitlab = {
      source  = "gitlabhq/gitlab"
      version = ">= 16.8.1"
    }
  }
}

variable "data_directory" {
  type = string
}

variable "image" {
  type = string
}

variable "stub_address" {
  type        = string
  description = "Address the stub's published port binds to."
}

variable "stub_host" {
  type        = string
  description = "Host Terraform reaches the stub's published port at."
}

locals {
  stub_port = 19080
  token     = "glrt-an-e2e-token"

  stub_healthcheck = [
    "CMD", "python", "-c",
    "import urllib.request as r; r.urlopen('http://127.0.0.1:8080/-/health')",
  ]
}

# No request at plan time: the stub starts with the apply, before the runner's registration.
provider "gitlab" {
  base_url         = "http://${var.stub_host}:${local.stub_port}/api/v4/"
  token            = "an-e2e-access-token"
  early_auth_check = false
}

resource "docker_image" "runner" {
  name         = var.image
  keep_locally = true
}

resource "docker_image" "stub" {
  name         = "python:3.13.9-slim"
  keep_locally = true
}

resource "docker_network" "e2e" {
  name = "gitlab-runner-e2e"
}

# The stub the gitlab provider registers the runner with.
resource "docker_container" "api" {
  name    = "gitlab-runner-e2e-api"
  image   = docker_image.stub.image_id
  command = ["python", "/stub.py"]
  env     = ["STUB_TOKEN=${local.token}"]
  wait    = true

  networks_advanced {
    name = docker_network.e2e.id
  }

  ports {
    internal = 8080
    external = local.stub_port
    ip       = var.stub_address
    protocol = "tcp"
  }

  healthcheck {
    test     = local.stub_healthcheck
    interval = "1s"
    retries  = 30
  }

  upload {
    file    = "/stub.py"
    content = file("${path.module}/stub.py")
  }
}

module "runner" {
  source = "../.."

  identifier  = "gitlab-runner-e2e"
  description = "Runner of the e2e suite."
  labels      = {}
  image_id    = docker_image.runner.image_id

  data_directory = var.data_directory

  runner_type = "instance"
  server_url  = "http://127.0.0.1:8080"

  jobs_tags    = ["e2e"]
  jobs_timeout = 600

  # Clear of the default port, which a runner of the host may hold.
  metrics_enabled = true
  metrics_port    = 19252

  depends_on = [docker_container.api]
}

# The stub the runner reaches on its own loopback: it shares the runner's network namespace, the
# runner's bridge having no DNS to resolve a stub's name.
resource "docker_container" "coordinator" {
  name         = "gitlab-runner-e2e-coordinator"
  image        = docker_image.stub.image_id
  command      = ["python", "/stub.py"]
  env          = ["STUB_TOKEN=${local.token}"]
  network_mode = "container:gitlab-runner-e2e"
  wait         = true

  healthcheck {
    test     = local.stub_healthcheck
    interval = "1s"
    retries  = 30
  }

  upload {
    file    = "/stub.py"
    content = file("${path.module}/stub.py")
  }

  # Docker records the container joined by its ID.
  lifecycle {
    ignore_changes = [network_mode]
  }

  depends_on = [module.runner]
}
