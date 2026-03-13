# Metadata -----------------------------------------------------------------------------------------

variable "identifier" {
  type        = string
  description = "Identifier (also used to name the runner and resources)."

  validation {
    condition     = regex("^[a-z]+(-[a-z0-9]+)*$", var.identifier) != null
    error_message = "Argument `identifier` must match regex ^[a-z]+(-[a-z0-9]+)*$."
  }
}

variable "description" {
  type        = string
  description = "Maintenance note."
}

variable "labels" {
  type        = map(string)
  description = "Labels attached to runner container."
}

# Application --------------------------------------------------------------------------------------

variable "enabled" {
  type        = bool
  description = "Toggle the runner container (started or stopped)."
  default     = true
}

variable "paused" {
  type        = bool
  description = "Pause the runner (do not process jobs)."
  default     = false
}

variable "env" {
  type        = map(string)
  description = "Define or overwrite environment variables for the runner (not the jobs)."
  default     = {}
}

variable "image_id" {
  type        = string
  description = "Runner image's ID."
}

# Resources ----------------------------------------------------------------------------------------

variable "cpu_set" {
  type        = string
  description = "The CPUs each runner can use (e.g. 0-4, 1,3)."
  default     = null
}

variable "cpu_shares" {
  type        = number
  description = "The ratio of CPU(s) each runner can use (e.g 0.5)."
  default     = null
}

variable "memory" {
  type        = number
  description = "Amount of memory (MBs) each runner can use."
  default     = 512

  validation {
    condition     = var.memory >= 64
    error_message = "Argument `memory` must be at least 64 (MB)."
  }
}

variable "swap" {
  type        = number
  description = "Amount of SWAP (MBs) each runner can use."
  default     = 128

  validation {
    condition     = var.swap >= 0
    error_message = "Argument `swap` must be 0 or a positive integer."
  }
}

# Networking ---------------------------------------------------------------------------------------

variable "hosts" {
  type        = map(string)
  description = "Add entries to container hosts file."
  default     = {}
}

# Storage ------------------------------------------------------------------------------------------

variable "data_directory" {
  type        = string
  description = "Where data will be persisted (volumes will be mounted as sub-directories)."
}

# Registration -------------------------------------------------------------------------------------

variable "runner_type" {
  type        = string
  description = <<EOT
    Runner type (instance, group or project).
    See https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/user_runner.
  EOT

  validation {
    condition     = contains(["instance", "group", "project"], var.runner_type)
    error_message = "Argument `runner_type` must be either \"instance\", \"group\" or \"project\"."
  }
}

variable "group_id" {
  type        = string
  description = "Group where to register the runner (only for group type)."
  default     = null
}

variable "project_id" {
  type        = string
  description = "Project where to register the runner (only for project type)."
  default     = null
}

variable "server_url" {
  type        = string
  description = "The GitLab server's URL."
}

variable "server_ca_cert" {
  type        = string
  description = "The GitLab server's custom CA certificate (content)."
  default     = null
}

# Global Settings ----------------------------------------------------------------------------------
# https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-global-section

variable "check_interval" {
  type        = number
  description = <<EOT
    Defines the interval length, in seconds, between the runner checking for new jobs.
    See https://docs.gitlab.com/runner/configuration/advanced-configuration.html#how-check_interval-works.
  EOT
  default     = 3

  validation {
    condition     = var.check_interval >= 1
    error_message = "Argument `check_interval` must be at least 1."
  }
}

variable "concurrency" {
  type        = number
  description = <<EOT
    Limits how many jobs can run concurrently, across all registered runners.
    Currently there is only one runner registered per instance of the module.
    See https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-global-section
  EOT
  default     = 10

  validation {
    condition     = var.concurrency >= 1
    error_message = "Argument `concurrency` must be at least 1."
  }
}

variable "log_format" {
  type        = string
  description = <<EOT
    Specifies the log format.
    See https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-global-section.
  EOT
  default     = "text"

  validation {
    condition     = contains(["runner", "text", "json"], var.log_format)
    error_message = "Argument `log_format` must be one of \"runner\", \"text\", or \"json\"."
  }
}

variable "log_level" {
  type        = string
  description = <<EOT
    Defines the log level (default: "warn").
    See https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-global-section.
  EOT
  default     = "warn"

  validation {
    condition     = contains(["debug", "info", "warn", "error", "fatal", "panic"], var.log_level)
    error_message = "Argument `log_level` must be one of \"debug\", \"info\", \"warn\", \"error\", \"fatal\", or \"panic\"."
  }
}

variable "debug_enabled" {
  type        = bool
  description = "Toggle debugging mode (for debugging purposes)."
  default     = false
}

variable "metrics_enabled" {
  type        = bool
  description = <<EOT
    Toggle the Prometheus metrics exporter integrated to the runner.
    See https://docs.gitlab.com/runner/monitoring/#configuration-of-the-metrics-http-server.
  EOT
  default     = false
}

variable "metrics_port" {
  type        = number
  description = "Host port used to expose the runner's Prometheus metrics exporter."
  default     = 9252

  validation {
    condition     = var.metrics_port >= 1 && var.metrics_port <= 65535
    error_message = "Argument `metrics_port` must be between 1 and 65535."
  }
}

# Jobs Core Settings -------------------------------------------------------------------------------
# https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runners-section

variable "jobs_concurrency" {
  type        = number
  description = <<EOT
    How many jobs can be handled concurrently by this registered runner. 0 means unlimited.
    See https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runners-section.
EOT
  default     = 0 # jobs

  validation {
    condition     = var.jobs_concurrency >= 0
    error_message = "Argument `jobs_concurrency` must be 0 (unlimited) or a positive integer."
  }
}

variable "jobs_env" {
  type        = map(string)
  description = <<EOT
    Define or overwrite environment variables for the jobs.
    These variables are converted to `--env "NAME=VALUE"` for the `gitlab-runner register`.
    See https://docs.gitlab.com/runner/commands/#gitlab-runner-register.
EOT
  default     = {}
}

variable "jobs_extra_hosts" {
  type        = map(string)
  description = "Hosts that should be defined in container environment."
  default     = {}
}

variable "jobs_locked" {
  type        = bool
  description = "Lock the runner to a specific group or project."
  default     = true
}

variable "jobs_output_limit" {
  type        = number
  description = <<EOT
    Maximum build log size in kilobytes.
    See https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runners-section.
EOT
  default     = 4096 # 4 MB

  validation {
    condition     = var.jobs_output_limit >= 1
    error_message = "Argument `jobs_output_limit` must be at least 1."
  }
}

variable "jobs_protected" {
  type        = bool
  description = "Est-ce que seule les branches protégées peuvent déclencher des jobs ?"
  default     = true
}

variable "jobs_requests_concurrency" {
  type        = number
  description = <<EOT
    Limit number of concurrent requests for new jobs from GitLab.
    See https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runners-section.
EOT
  default     = 1 # requests

  validation {
    condition     = var.jobs_requests_concurrency >= 1
    error_message = "Argument `jobs_requests_concurrency` must be at least 1."
  }
}

variable "jobs_run_untagged" {
  type        = bool
  description = "Execute jobs even if they are not tagged."
  default     = false
}

variable "jobs_tags" {
  type        = list(string)
  description = <<EOT
    Tags associated with the runner, typically used to control the dispatching of jobs.
    See https://docs.gitlab.com/ce/ci/runners/#using-tags.
  EOT
}

variable "jobs_timeout" {
  type        = number
  description = <<EOT
    Gives the jobs time to complete (in seconds).
    See https://docs.gitlab.com/ee/api/runners.html.
  EOT
  default     = 3600

  validation {
    condition     = var.jobs_timeout >= 1
    error_message = "Argument `jobs_timeout` must be at least 1."
  }
}

# Jobs Docker Executor Settings --------------------------------------------------------------------
# https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runnersdocker-section

variable "jobs_allowed_images" {
  type        = list(string)
  description = <<EOT
    Restrict the source from where the images can be pulled (using wildcard patterns).
    See https://docs.gitlab.com/runner/executors/docker.html#restrict-docker-pull-policies.
EOT
  default     = ["*/*:*"]
}

variable "jobs_allowed_pull_policies" {
  type        = list(string)
  description = "https://docs.gitlab.com/runner/executors/docker.html#restrict-docker-pull-policies"
  default     = ["always", "if-not-present", "never"]
}

variable "jobs_allowed_services" {
  type        = list(string)
  description = "https://docs.gitlab.com/runner/executors/docker.html#restrict-docker-pull-policies"
  default     = ["*/*:*"]
}

# https://docs.gitlab.com/runner/executors/docker.html#using-multiple-pull-policies
variable "jobs_pull_policy" {
  type        = list(string)
  description = "Will be attempted in order from left to right until a pull attempt is successful, or the list is exhausted."
  default     = ["always", "if-not-present"]
}

# https://docs.gitlab.com/runner/executors/docker.html#the-privileged-mode
variable "jobs_privileged" {
  type        = bool
  description = "Grant privileged mode to the build container and all services."
  default     = false
}

variable "jobs_volumes" {
  type        = list(string)
  description = "Additional volume mounts to pass to runner jobs."
  default     = []
}
