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

run "metrics_bind_to_loopback_by_default" {
  command = plan

  variables {
    metrics_enabled = true
  }

  assert {
    condition = one(docker_container.runner.ports).ip == "127.0.0.1"
    error_message = join(" ", [
      "The unauthenticated metrics endpoint must be published on loopback",
      "unless asked otherwise.",
    ])
  }
}

run "metrics_bind_to_the_listener_address" {
  command = plan

  variables {
    metrics_enabled  = true
    listener_address = "0.0.0.0"
  }

  assert {
    condition     = one(docker_container.runner.ports).ip == "0.0.0.0"
    error_message = "The metrics port must be published on `listener_address`."
  }
}

run "metrics_publish_no_port_while_disabled" {
  command = plan

  assert {
    condition     = length(docker_container.runner.ports) == 0
    error_message = "No port must be published while the metrics are disabled."
  }
}
