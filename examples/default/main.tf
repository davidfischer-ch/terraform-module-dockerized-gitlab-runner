resource "docker_image" "runner" {
  name         = "gitlab/gitlab-runner:latest"
  keep_locally = true
}

data "gitlab_group" "runner" {
  full_path = var.runner_group_path
}

module "runner" {
  source = "git::https://github.com/davidfischer-ch/terraform-module-dockerized-gitlab-runner.git?ref=2.1.1"

  identifier  = "my-runner"
  description = "Dockerized runner for CI/CD jobs."

  labels   = {}
  image_id = docker_image.runner.image_id

  # Storage

  data_directory = "/data/my-runner"

  # Registration

  server_url  = var.gitlab_url
  runner_type = "group"
  group_id    = data.gitlab_group.runner.id

  # Global Settings

  concurrency = 4
  log_level   = "info"

  # Jobs Core Settings

  jobs_protected = false

  jobs_tags = [
    "docker",
    "linux",
  ]
}
