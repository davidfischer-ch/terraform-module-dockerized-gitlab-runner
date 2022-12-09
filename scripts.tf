resource "local_file" "entrypoint_script" {
  filename             = "${local.host_scripts_directory}/entrypoint"
  file_permission      = "0755"
  directory_permission = "0755"

  content = <<EOT
#!/bin/bash
set -e

# Doesn't work properly
# trap "${local.container_scripts_directory}/cleanup" SIGQUIT
# trap "${local.container_scripts_directory}/cleanup" SIGTERM

echo "Cleanup existing runners (if any)"
${local.container_scripts_directory}/cleanup

echo "Copy configuration"
cp "$TEMPLATE_FILE" "$CONFIG_FILE"

# See https://docs.gitlab.com/runner/configuration/advanced-configuration.html

echo "Register the runner to ${var.registration_url}"
MAX_ATTEMPTS=${var.registration_retries}
for i in $(seq 1 "$MAX_ATTEMPTS"); do
  echo "Registration attempt $i of $MAX_ATTEMPTS"
  /entrypoint ${var.debug_enabled ? "--debug" : ""} register \
${join(" \\\n", formatlist("    %s", local.register_options))}
  retval=$?
  if [ $retval = 0 ]; then
    break
  elif [ $i = $MAX_ATTEMPTS ]; then
    exit 1
  fi
  sleep ${var.registration_interval}
done

echo "Drop duplicated /builds and /cache in generated configuration"
echo "Fix https://gitlab.com/gitlab-org/gitlab-runner/-/issues/2538"
# Example : volumes = ["/data/gitlab-runner/cache:/cache:rw", ..., "/builds", "/cache"]
sed -i -e 's#volumes = .*#volumes = ${jsonencode(local.formatted_jobs_volumes)}#' "$CONFIG_FILE"

echo "Start the runner"
exec /entrypoint run --user=gitlab-runner --working-directory=${local.container_home_directory}
EOT
}

resource "local_file" "check_live_script" {
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

resource "local_file" "cleanup_script" {
  filename             = "${local.host_scripts_directory}/cleanup"
  file_permission      = "0755"
  directory_permission = "0755"

  content = <<EOT
#!/bin/bash
set -e

if [[ -f "$CONFIG_FILE" ]]; then
  echo 'Unregister all runners and drop configuration'
  /entrypoint unregister --all-runners
  rm "$CONFIG_FILE"
fi

EOT
}
