locals {
  container_home_directory    = "/home/gitlab-runner"
  container_builds_directory  = "/builds"
  container_cache_directory   = "/cache"
  container_config_directory  = "${local.container_home_directory}/.gitlab-runner"
  container_scripts_directory = "/scripts"

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
  })

  jobs_volumes = concat(var.jobs_volumes, [
    "${system_folder.builds.path}:${local.container_builds_directory}:rw",
    "${system_folder.cache.path}:${local.container_cache_directory}:rw"
  ])
}
