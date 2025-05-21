resource "docker_container" "runner" {

  lifecycle {
    replace_triggered_by = [
      local_file.config,
      local_file.check_live,
      local_file.entrypoint
    ]
  }

  entrypoint = ["/bin/bash", "${local.container_scripts_directory}/entrypoint"]
  image      = var.image_id
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
  stop_timeout = var.jobs_timeout

  env = formatlist("%s=%s", keys(local.env), values(local.env))

  dynamic "host" {
    for_each = var.hosts
    content {
      host = host.key
      ip   = host.value
    }
  }

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

  # Builds owner root:root
  volumes {
    container_path = local.container_builds_directory
    host_path      = local.host_builds_directory
    read_only      = false
  }

  # Cache owner root:root
  volumes {
    container_path = local.container_cache_directory
    host_path      = local.host_cache_directory
    read_only      = false
  }

  # Configuration owner root:root
  volumes {
    container_path = local.container_config_directory
    host_path      = local.host_config_directory
    read_only      = true
  }

  # Scripts owner root:root
  volumes {
    container_path = local.container_scripts_directory
    host_path      = local.host_scripts_directory
    read_only      = true
  }

  # Storage owner root:root mode 1777
  volumes {
    container_path = local.container_storage_directory
    host_path      = local.host_storage_directory
    read_only      = false
  }
}
