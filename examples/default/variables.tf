variable "gitlab_url" {
  type        = string
  description = "GitLab instance URL."
  default     = "https://gitlab.example.com"
}

variable "gitlab_token" {
  type        = string
  sensitive   = true
  description = "GitLab personal access token with api scope."
}

variable "runner_group_path" {
  type        = string
  description = "Full path of the GitLab group to register the runner to."
  default     = "my-group"
}
