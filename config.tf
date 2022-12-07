resource "local_file" "config_template" {
  filename             = "${local.host_scripts_directory}/config.toml"
  file_permission      = "0644"
  directory_permission = "0755"

  content = <<EOT
concurrent     = ${var.concurrency}
check_interval = ${var.check_interval}
log_level      = "${var.log_level}"
log_format     = "${var.log_format}"

%{if var.metrics_enabled}
listen_address = "[::]:9252"
%{endif}

EOT
}
