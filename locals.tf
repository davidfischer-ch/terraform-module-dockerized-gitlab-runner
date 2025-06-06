locals {
  container_home_directory    = "/home/gitlab-runner"
  container_builds_directory  = "/builds"
  container_cache_directory   = "/cache"
  container_config_directory  = "${local.container_home_directory}/.gitlab-runner"
  container_scripts_directory = "/scripts"
  container_storage_directory = "/storage"

  host_builds_directory  = "${var.data_directory}/builds"
  host_cache_directory   = "${var.data_directory}/cache"
  host_config_directory  = "${var.data_directory}/config"
  host_scripts_directory = "${var.data_directory}/scripts"
  host_storage_directory = "${var.data_directory}/storage"

  env = merge(var.env, {
    HOME          = local.container_home_directory
    RUNNER_TOKEN  = gitlab_user_runner.self.token
    TEMPLATE_FILE = "${local.container_config_directory}/config.toml"
    CONFIG_FILE   = "/tmp/config.toml"
  })

  jobs_env = merge(var.jobs_env, {
    # Fix the helper image trying to write to / directory
    HOME = "/tmp"

    STORAGE_DIR = local.container_storage_directory
  })

  jobs_extra_hosts = [for host, ip in var.jobs_extra_hosts : "${host}:${ip}"]

  jobs_volumes = concat(var.jobs_volumes, [
    "${local.host_builds_directory}:${local.container_builds_directory}:rw",
    "${local.host_cache_directory}:${local.container_cache_directory}:rw",
    "${local.host_storage_directory}:${local.container_storage_directory}:rw"
  ])
}
