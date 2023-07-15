resource "local_file" "config" {
  filename             = "${local.host_config_directory}/config.toml"
  file_permission      = "0644"
  directory_permission = "0755"

  content = <<EOT
concurrent       = ${var.concurrency}
check_interval   = ${var.check_interval}
log_level        = "${var.log_level}"
log_format       = "${var.log_format}"
shutdown_timeout = ${var.jobs_timeout}

%{if var.metrics_enabled}
listen_address = "[::]:9252"
%{endif}

[session_server]
  session_timeout = 1800

[[runners]]
  name = "${var.identifier}"
  url = "${var.server_url}"
  token = "__RUNNER_TOKEN__"
  %{if var.server_ca_cert != null}
  tls-ca-file="${local.container_config_directory}/certs/server-ca.crt"
  %{endif}
  limit = ${var.jobs_concurrency}
  executor = "docker"
  builds_dir = "${local.container_builds_directory}"
  cache_dir = "${local.container_cache_directory}"
  environment = ${jsonencode([for k, v in local.jobs_env : "${k}=${v}"])}
  request_concurrency = ${var.jobs_requests_concurrency}
  output_limit = ${var.jobs_output_limit}
  [runners.custom_build_dir]
  [runners.cache]
    MaxUploadedArchiveSize = 0
    [runners.cache.s3]
    [runners.cache.gcs]
    [runners.cache.azure]
  [runners.docker]
    allowed_images = ${jsonencode(var.jobs_allowed_images)}
    allowed_pull_policies = ${jsonencode(var.jobs_allowed_pull_policies)}
    allowed_services = ${jsonencode(var.jobs_allowed_services)}
    disable_cache = false
    disable_entrypoint_overwrite = false
    image = "you-must-specify-image-in-cy"
    oom_kill_disable = false
    privileged = ${var.jobs_privileged}
    pull_policy = ${jsonencode(var.jobs_pull_policy)}
    shm_size = 0
    tls_verify = false
    volumes = ${jsonencode(local.jobs_volumes)}

EOT
}

resource "local_sensitive_file" "server_ca_cert" {
  # Marked as sensitive also to hide its content on diff
  count = var.server_ca_cert == null ? 0 : 1

  filename             = "${local.host_config_directory}/certs/server-ca.crt"
  file_permission      = "0644"
  directory_permission = "0755"

  content = var.server_ca_cert
}
