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

run "healthcheck_runs_the_live_check" {
  command = plan

  assert {
    condition = (
      docker_container.runner.healthcheck[0].test
      == tolist(["CMD", "/bin/bash", "/scripts/check-live"])
    )
    error_message = "Docker runs no probe unless the healthcheck test starts with CMD or CMD-SHELL."
  }
}
