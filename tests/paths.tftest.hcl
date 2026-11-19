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

run "storage_path_reaches_the_shell_as_one_word" {
  command = plan

  variables {
    data_directory = "/data/a runner's; id"
  }

  assert {
    condition     = local.storage_command == "chmod 1777 '/data/a runner'\\''s; id/storage'"
    error_message = "The storage path must reach the shell as one single-quoted word."
  }
}
