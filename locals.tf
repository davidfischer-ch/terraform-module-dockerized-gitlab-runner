locals {
  container_home_directory         = "/home/gitlab-runner"
  container_builds_directory       = "/builds"
  container_cache_directory        = "/cache"
  container_config_directory       = "${local.container_home_directory}/.gitlab-runner"
  container_certificates_directory = "${local.container_config_directory}/certs"
  container_scripts_directory      = "/scripts"

  host_scripts_directory = "${var.data_directory}/${var.identifier}/scripts"

  env = merge(var.env, local.forced_env)

  forced_env = {
    HOME = local.container_home_directory

    # RUNNER_NAME = var.identifier

    TEMPLATE_FILE = "${local.container_scripts_directory}/config.toml"
    CONFIG_FILE   = "${local.container_config_directory}/config.toml"

    CI_SERVER_URL   = var.gitlab_server_url
    CI_SERVER_TOKEN = var.token

    # CI_SERVER_TLS_CA_FILE
    # CI_SERVER_TLS_CERT_FILE
    # CI_SERVER_TLS_KEY_FILE

    # REGISTER_ACCESS_LEVEL     = "${var.jobs_protected ? "ref" : "not"}_protected"
    # REGISTER_LEAVE_RUNNER     = false
    # REGISTER_LOCKED           = var.jobs_locked
    # REGISTER_MAINTENANCE_NOTE = var.description
    # REGISTER_MAXIMUM_TIMEOUT  = 0
    # REGISTER_NON_INTERACTIVE  = true
    # REGISTER_PAUSED           = var.paused
    # REGISTER_RUN_UNTAGGED     = var.jobs_run_untagged
    REGISTRATION_TOKEN        = var.registration_token

    # CLONE_URL = var.jobs_clone_url

    # RUNNER_BUILDS_DIR          = local.container_builds_directory
    # RUNNER_CACHE_DIR           = local.container_cache_directory

    # Wasn't working properly (encoding issues leading to strange config.toml)
    # RUNNER_ENV                 = jsonencode(local.formatted_jobs_env)

    # RUNNER_EXECUTOR            = "docker"
    # RUNNER_LIMIT               = var.jobs_concurrency
    # RUNNER_OUTPUT_LIMIT        = var.jobs_output_limit
    # RUNNER_REQUEST_CONCURRENCY = var.jobs_requests_concurrency
    # RUNNER_TAG_LIST            = join(",", var.jobs_tags)

    # RUNNER_PRE_CLONE_SCRIPT
    # RUNNER_POST_CLONE_SCRIPT
    # RUNNER_PRE_BUILD_SCRIPT
    # RUNNER_POST_BUILD_SCRIPT
    # RUNNER_DEBUG_TRACE_DISABLED
    # RUNNER_SHELL

    # DOCKER_HOST
    # DOCKER_CERT_PATH
    # DOCKER_TLS_VERIFY
    # DOCKER_HOSTNAME

    # DOCKER_IMAGE = "you-must-specify-image-in-cy"

    # DOCKER_RUNTIME
    # DOCKER_MEMORY
    # DOCKER_MEMORY_SWAP
    # DOCKER_MEMORY_RESERVATION
    # DOCKER_CPUSET_CPUS
    # DOCKER_CPUS
    # DOCKER_CPU_SHARES
    # DOCKER_DNS
    # DOCKER_DNS_SEARCH

    # DOCKER_PRIVILEGED = var.jobs_privileged

    # DOCKER_DISABLE_ENTRYPOINT_OVERWRITE
    # DOCKER_USER
    # DOCKER_USERNS_MODE
    # DOCKER_CAP_ADD
    # DOCKER_CAP_DROP
    # DOCKER_OOM_KILL_DISABLE
    # DOCKER_OOM_SCORE_ADJUST
    # DOCKER_SECURITY_OPT
    # DOCKER_DEVICES
    # DOCKER_DEVICE_CGROUP_RULES
    # DOCKER_GPUS
    # DOCKER_DISABLE_CACHE

    # DOCKER_VOLUMES = join(",", var.jobs_volumes)

    # DOCKER_VOLUME_DRIVER
    # DOCKER_VOLUME_DRIVER_OPS
    # DOCKER_CACHE_DIR
    # DOCKER_EXTRA_HOSTS
    # DOCKER_VOLUMES_FROM
    # DOCKER_NETWORK_MODE
    # DOCKER_LINKS
    # DOCKER_WAIT_FOR_SERVICES_TIMEOUT

    # Wasn't working properly (encoding issues leading to strange config.toml)
    # DOCKER_ALLOWED_IMAGES        = join(",", [for i in var.jobs_allowed_images: "\"${i}\""])
    # DOCKER_ALLOWED_PULL_POLICIES = join(",", [for p in var.jobs_allowed_pull_policies: "\"${p}\""])
    # DOCKER_ALLOWED_SERVICES      = join(",", [for s in var.jobs_allowed_services: "\"${s}\""])
    # DOCKER_PULL_POLICY           = join(",", [for p in var.jobs_pull_policy: "\"${p}\""])

    # DOCKER_SHM_SIZE
    # DOCKER_TMPFS
    # DOCKER_SERVICES_TMPFS
    # DOCKER_SYSCTLS
    # DOCKER_HELPER_IMAGE
    # DOCKER_HELPER_IMAGE_FLAVOR

    # CUSTOM_CONFIG_EXEC
    # CUSTOM_CONFIG_EXEC_TIMEOUT
    # CUSTOM_PREPARE_EXEC
    # CUSTOM_PREPARE_EXEC_TIMEOUT
    # CUSTOM_RUN_EXEC
    # CUSTOM_CLEANUP_EXEC
    # CUSTOM_CLEANUP_EXEC_TIMEOUT
    # CUSTOM_GRACEFUL_KILL_TIMEOUT
    # CUSTOM_FORCE_KILL_TIMEOUT

    # RUNNER_PRE_CLONE_SCRIPT
    # RUNNER_POST_CLONE_SCRIPT
    # RUNNER_PRE_BUILD_SCRIPT
    # RUNNER_POST_BUILD_SCRIPT
    # RUNNER_SHELL
  }

  register_options = concat(
    [
      "--non-interactive",
      "--name=\"${var.identifier}\"",
      "--access-level=\"${var.jobs_protected ? "ref" : "not"}_protected\"",
      "--builds-dir=\"${local.container_builds_directory}\"",
      "--cache-dir=\"${local.container_cache_directory}\"",
      "--leave-runner=false",
      "--limit=${var.jobs_concurrency}",
      "--locked=${var.jobs_locked}",
      "--maintenance-note=\"${var.description}\"",
      "--maximum-timeout=0",
      "--output-limit=${var.jobs_output_limit}",
      "--paused=${var.paused}",
      "--request-concurrency=${var.jobs_requests_concurrency}",
      "--run-untagged=${var.jobs_run_untagged}",
      "--tag-list=\"${join(",", var.jobs_tags)}\""
    ],
    formatlist("--env=%s", local.formatted_jobs_env),
    formatlist("--docker-allowed-images=\"%s\"", var.jobs_allowed_images),
    formatlist("--docker-allowed-pull-policies=\"%s\"", var.jobs_allowed_pull_policies),
    formatlist("--docker-allowed-services=\"%s\"", var.jobs_allowed_services),
    formatlist("--docker-pull-policy=\"%s\"", var.jobs_pull_policy),
    [
      "--docker-image=\"you-must-specify-image-in-cy\"",
      "--docker-privileged=${var.jobs_privileged}",
      "--executor=\"docker\""
    ]
  )

  formatted_jobs_env = [for k, v in merge(var.jobs_env, local.jobs_forced_env) : "\"${k}\"=\"${v}\""]

  jobs_forced_env = {
    # Fix the helper image trying to write to / directory
    HOME = "/tmp"
  }
}
