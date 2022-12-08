resource "docker_image" "runner" {
  name = "${var.image_url}:${var.image_tag}"
}

resource "docker_container" "runner" {

  lifecycle {
    replace_triggered_by = [
      local_file.config_template,
      local_file.check_live_script,
      local_file.cleanup_script,
      local_file.entrypoint_script
    ]
  }

  entrypoint = ["/bin/bash", "${local.container_scripts_directory}/entrypoint"]
  image      = docker_image.runner.image_id
  name       = var.identifier

  must_run = var.enabled
  start    = var.enabled
  restart  = "always"
  wait     = false

  cpu_set     = var.cpu_set
  cpu_shares  = var.cpu_shares
  memory      = var.memory
  memory_swap = var.memory + var.swap

  # https://docs.gitlab.com/runner/commands/#signals
  stop_signal  = "SIGQUIT"
  stop_timeout = var.stop_timeout

  env = formatlist("%s=%s", keys(local.env), values(local.env))

  dynamic "labels" {
    for_each = var.labels
    content {
      label = labels.key
      value = labels.value
    }
  }

  dynamic "ports" {
    for_each = var.metrics_enabled ? ["it is :)"] : []
    content {
      internal = 9252
      external = var.metrics_port
      ip       = "0.0.0.0"
      protocol = "tcp"
    }
  }

  healthcheck {
    interval     = "10s"
    retries      = 3
    start_period = "1m0s"
    test         = ["/bin/bash", "${local.container_scripts_directory}/check-live"]
    timeout      = "1s"
  }

  volumes {
    container_path = "/var/run/docker.sock"
    host_path      = "/var/run/docker.sock"
    read_only      = false
  }

  # Builds
  volumes {
    container_path = local.container_builds_directory
    host_path      = "${var.data_directory}/${var.identifier}/builds"
    read_only      = false
  }

  # Cache
  volumes {
    container_path = local.container_cache_directory
    host_path      = local.host_cache_directory
    read_only      = false
  }

  # Configuration
  volumes {
    container_path = local.container_config_directory
    host_path      = "${var.data_directory}/${var.identifier}/config"
    read_only      = false
  }

  # Certificates
  volumes {
    container_path = local.container_certificates_directory
    host_path      = "${var.data_directory}/${var.identifier}/certificates"
    read_only      = true
  }

  # Scripts
  volumes {
    container_path = local.container_scripts_directory
    host_path      = local.host_scripts_directory
    read_only      = true
  }
}
