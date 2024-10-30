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
}

variable "paused" {
  type        = bool
  description = "Pause the runner (do not process jobs)."
}

variable "env" {
  type        = map(string)
  default     = {}
  description = "Define or overwrite environment variables for the runner (not the jobs)."
}

variable "hosts" {
  type        = map(string)
  default     = {}
  description = "Set additional hosts (fqdn -> ip)."
}

variable "image_id" {
  type        = string
  description = "Runner image's ID."
}

# Resources ----------------------------------------------------------------------------------------

variable "cpu_set" {
  type        = string
  default     = null
  description = "The CPUs each runner can use (e.g. 0-4, 1,3)."
}

variable "cpu_shares" {
  type        = number
  default     = null
  description = "The ratio of CPU(s) each runner can use (e.g 0.5)."
}

variable "memory" {
  type        = number
  default     = 512
  description = "Amount of memory (MBs) each runner can use."
}

variable "swap" {
  type        = number
  default     = 128
  description = "Amount of SWAP (MBs) each runner can use."
}

# Storage ------------------------------------------------------------------------------------------

variable "data_directory" {
  type        = string
  description = "Where data will be persisted (volumes will be mounted as sub-directories)."
}

# Registration -------------------------------------------------------------------------------------

variable "server_url" {
  type        = string
  description = "The GitLab server's URL."
}

variable "server_ca_cert" {
  type        = string
  default     = null
  description = "The GitLab server's custom CA certificate (content)."
}

variable "registration_url" {
  type        = string
  description = "Where the runner is registered (for documentation purposes)."
}

variable "registration_token" {
  type        = string
  description = <<EOT
    Token used to register the runner into a project, group or even the instace of GitLab server.
    See https://docs.gitlab.com/ee/api/runners.html#registration-and-authentication-tokens.
  EOT
  sensitive   = true
}

# Global Settings ----------------------------------------------------------------------------------
# https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-global-section

variable "check_interval" {
  type        = number
  default     = 3
  description = <<EOT
    Defines the interval length, in seconds, between the runner checking for new jobs.
    See https://docs.gitlab.com/runner/configuration/advanced-configuration.html#how-check_interval-works.
  EOT
}

variable "concurrency" {
  type        = number
  default     = 10
  description = <<EOT
    Limits how many jobs can run concurrently, across all registered runners.
    Currently there is only one runner registered per instance of the module.
    See https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-global-section
  EOT
}

variable "log_format" {
  type        = string
  default     = "text"
  description = <<EOT
    Specifies the log format.
    See https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-global-section.
  EOT
  validation {
    condition     = contains(["runner", "text", "json"], var.log_format)
    error_message = "Argument `log_format` must be one of \"runner\", \"text\", or \"json\"."
  }
}

variable "log_level" {
  type        = string
  default     = "info"
  description = <<EOT
    Defines the log level.
    See https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-global-section.
  EOT
  validation {
    condition     = contains(["debug", "info", "warn", "error", "fatal", "panic"], var.log_level)
    error_message = "Argument `log_level` must be one of \"debug\", \"info\", \"warn\", \"error\", \"fatal\", or \"panic\"."
  }
}

variable "debug_enabled" {
  type        = bool
  default     = false
  description = "Toggle debugging mode (for debugging purposes)."
}

variable "metrics_enabled" {
  type        = bool
  default     = false
  description = <<EOT
    Toggle the Prometheus metrics exporter integrated to the runner.
    See https://docs.gitlab.com/runner/monitoring/#configuration-of-the-metrics-http-server.
  EOT
}

variable "metrics_port" {
  type        = number
  default     = 9252
  description = "Host port used to expose the runner's Prometheus metrics exporter."
}

# Jobs Core Settings -------------------------------------------------------------------------------
# https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runners-section

variable "jobs_concurrency" {
  type        = number
  default     = 0 # jobs
  description = <<EOT
    How many jobs can be handled concurrently by this registered runner. 0 means unlimited.
    See https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runners-section.
EOT
}

variable "jobs_env" {
  type        = map(string)
  default     = {}
  description = <<EOT
    Define or overwrite environment variables for the jobs.
    These variables are converted to `--env "NAME=VALUE"` for the `gitlab-runner register`.
    See https://docs.gitlab.com/runner/commands/#gitlab-runner-register.
EOT
}

variable "jobs_locked" {
  type        = bool
  default     = true
  description = "Lock the runner to a specific group or project."
}

variable "jobs_output_limit" {
  type        = number
  default     = 4096 # 4 MB
  description = <<EOT
    Maximum build log size in kilobytes.
    See https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runners-section.
EOT
}

variable "jobs_protected" {
  type        = bool
  default     = true
  description = "Est-ce que seule les branches protégées peuvent déclencher des jobs ?"
}

variable "jobs_requests_concurrency" {
  type        = number
  default     = 1 # requests
  description = <<EOT
    Limit number of concurrent requests for new jobs from GitLab.
    See https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runners-section.
EOT
}

variable "jobs_run_untagged" {
  type        = bool
  default     = false
  description = "Execute jobs even if they are not tagged."
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
  default     = 3600
  description = <<EOT
    Gives the jobs time to complete (in seconds).
    See https://docs.gitlab.com/ee/api/runners.html.
  EOT
}

# Jobs Docker Executor Settings --------------------------------------------------------------------
# https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runnersdocker-section

variable "jobs_allowed_images" {
  type        = list(string)
  default     = ["*/*:*"]
  description = <<EOT
    Restrict the source from where the images can be pulled (using wildcard patterns).
    See https://docs.gitlab.com/runner/executors/docker.html#restrict-docker-pull-policies.
EOT
}

variable "jobs_allowed_pull_policies" {
  type        = list(string)
  default     = ["always", "if-not-present", "never"]
  description = "https://docs.gitlab.com/runner/executors/docker.html#restrict-docker-pull-policies"
}

variable "jobs_allowed_services" {
  type        = list(string)
  default     = ["*/*:*"]
  description = "https://docs.gitlab.com/runner/executors/docker.html#restrict-docker-pull-policies"
}

# https://docs.gitlab.com/runner/executors/docker.html#using-multiple-pull-policies
variable "jobs_pull_policy" {
  type        = list(string)
  default     = ["always", "if-not-present"]
  description = "Will be attempted in order from left to right until a pull attempt is successful, or the list is exhausted."
}

# https://docs.gitlab.com/runner/executors/docker.html#the-privileged-mode
variable "jobs_privileged" {
  type        = bool
  default     = false
  description = "Grant privileged mode to the build container and all services."
}

variable "jobs_volumes" {
  type    = list(string)
  default = []
}
