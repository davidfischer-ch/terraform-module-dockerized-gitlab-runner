locals {
  container_home_directory    = "/home/gitlab-runner"
  container_builds_directory  = "/builds"
  container_cache_directory   = "/cache"
  container_config_directory  = "${local.container_home_directory}/.gitlab-runner"
  container_data_directory    = "/data"
  container_scripts_directory = "/scripts"

  host_builds_directory  = "${var.data_directory}/builds"
  host_cache_directory   = "${var.data_directory}/cache"
  host_config_directory  = "${var.data_directory}/config"
  host_data_directory    = "${var.data_directory}/data"
  host_scripts_directory = "${var.data_directory}/scripts"

  access_level = "${var.jobs_protected ? "ref" : "not"}_protected"

  env = merge(var.env, {
    HOME          = local.container_home_directory
    RUNNER_TOKEN  = gitlab_runner.runner.authentication_token
    TEMPLATE_FILE = "${local.container_config_directory}/config.toml"
    CONFIG_FILE   = "/tmp/config.toml"
  })

  jobs_env = merge(var.jobs_env, {
    # Fix the helper image trying to write to / directory
    HOME = "/tmp"

    BUILDS_DIR = local.container_builds_directory
    CACHE_DIR  = local.container_cache_directory
    DATA_DIR   = local.container_data_directory
  })

  jobs_extra_hosts = [for host, ip in var.jobs_extra_hosts : "${host}:${ip}"]

  jobs_volumes = concat(var.jobs_volumes, [
    "${local.host_builds_directory}:${local.container_builds_directory}:rw",
    "${local.host_cache_directory}:${local.container_cache_directory}:rw",
    "${local.host_data_directory}:${local.container_data_directory}:rw"
  ])
}
