resource "system_file" "entrypoint" {
  path = "${system_folder.scripts.path}/entrypoint"
  uid  = 0
  gid  = 0
  mode = "755"

  content = <<EOT
#!/bin/bash
set -e

# HACK FOR : Allow token to be passed by environment variable
# See: https://gitlab.com/gitlab-org/gitlab-runner/-/issues/2458
sed -e "s:__RUNNER_TOKEN__:$RUNNER_TOKEN:g" "$TEMPLATE_FILE" > "$CONFIG_FILE"

echo "Start the runner"
exec /entrypoint run \
  --user=gitlab-runner \
  --working-directory="${local.container_home_directory}"
EOT
}

resource "system_file" "check_live" {
  path = "${system_folder.scripts.path}/check-live"
  uid  = 0
  gid  = 0
  mode = "755"

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
