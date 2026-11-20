mock_provider "docker" {}
mock_provider "gitlab" {}
mock_provider "local" {}

variables {
  identifier     = "my-runner"
  description    = "Runner of the tests."
  labels         = {}
  image_id       = "sha256:0123456789abcdef"
  data_directory = "/data/my-runner"
  runner_type    = "group"
  group_id       = "42"
  server_url     = "https://gitlab.example.com"
  jobs_tags      = ["docker"]
}

run "replacement_lets_the_jobs_drain" {
  command = plan

  variables {
    jobs_timeout = 1800
  }

  assert {
    condition = docker_container.runner.destroy_grace_seconds == 1800
    error_message = join(" ", [
      "Terraform must give the runner `jobs_timeout`",
      "to finish its jobs before killing it.",
    ])
  }
}

run "jobs_timeout_below_the_gitlab_minimum_is_refused" {
  command = plan

  variables {
    jobs_timeout = 599
  }

  expect_failures = [var.jobs_timeout]
}
