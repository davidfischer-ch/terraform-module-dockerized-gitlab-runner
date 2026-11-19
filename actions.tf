# On-demand operations on the runner, run with `terraform apply -invoke=<action address>`.

# Check the runner's registration against the GitLab server from the report of
# `gitlab-runner verify`, which exits 0 on a failed check.
action "docker_exec" "verify" {
  config {
    container = docker_container.runner.name
    command = ["sh", "-c", <<-EOT
      report=$(gitlab-runner verify 2>&1)
      printf '%s\n' "$report"
      case "$report" in
        *'Verifying runner... is valid'* | *'Verifying runner... is alive'*) ;;
        *) exit 1 ;;
      esac
    EOT
    ]
  }
}
