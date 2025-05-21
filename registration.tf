resource "gitlab_user_runner" "self" {
  runner_type = "${var.runner_type}_type"
  group_id    = var.group_id
  project_id  = var.project_id
  description = var.description

  access_level    = "${var.jobs_protected ? "ref" : "not"}_protected"
  locked          = var.jobs_locked
  paused          = var.paused
  maximum_timeout = var.jobs_timeout
  tag_list        = var.jobs_tags
  untagged        = var.jobs_run_untagged
}
