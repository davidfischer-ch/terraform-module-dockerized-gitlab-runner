mock_provider "docker" {}
mock_provider "local" {}

mock_provider "gitlab" {
  mock_resource "gitlab_user_runner" {
    override_during = plan
    defaults = {
      token = "glrt-0123456789abcdef"
    }
  }
}

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

run "token_stays_out_of_the_container_metadata" {
  command = plan

  assert {
    condition     = nonsensitive(local_sensitive_file.token.content) == "glrt-0123456789abcdef"
    error_message = "The token file must hold the runner's token."
  }

  assert {
    condition = alltrue([
      for entry in docker_container.runner.env : !strcontains(entry, "glrt-0123456789abcdef")
    ])
    error_message = join(" ", [
      "The runner token must not be in the container's environment,",
      "which docker inspect prints.",
    ])
  }
}

run "token_is_readable_by_its_owner_alone" {
  command = plan

  assert {
    condition     = local_sensitive_file.token.file_permission == "0600"
    error_message = "The token file must be readable by its owner alone."
  }

  assert {
    condition = strcontains(local_file.entrypoint.content, "umask 077\n")
    error_message = join(" ", [
      "The configuration the token is substituted into",
      "must be readable by its owner alone.",
    ])
  }
}
