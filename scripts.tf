resource "local_file" "entrypoint" {
  filename             = "${local.host_scripts_directory}/entrypoint"
  file_permission      = "0755"
  directory_permission = "0755"

  content = <<EOT
#!/bin/bash
set -e

# Builtins substitute the token, keeping it out of every process's arguments, into a file only
# root reads. See https://gitlab.com/gitlab-org/gitlab-runner/-/issues/2458.
umask 077
template=$(<"$TEMPLATE_FILE")
token=$(<"$TOKEN_FILE")
printf '%s\n' "$${template//__RUNNER_TOKEN__/"$token"}" > "$CONFIG_FILE"

echo "Start the runner"
exec /entrypoint run \
  --user=gitlab-runner \
  --working-directory="${local.container_home_directory}"
EOT
}

resource "local_file" "check_live" {
  filename             = "${local.host_scripts_directory}/check-live"
  file_permission      = "0755"
  directory_permission = "0755"

  content = <<EOT
#!/bin/bash
set -e

if /usr/bin/pgrep -f .*entrypoint; then
  exit 0
elif /usr/bin/pgrep gitlab.*runner; then
  exit 0
else
  exit 1
fi
EOT
}
