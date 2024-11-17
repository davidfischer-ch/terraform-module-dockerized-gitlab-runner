# Create jobs persistent directory

resource "local_file" "jobs_storage_touch" {
  filename             = "local.host_storage_directory/.touch"
  content              = "Used to create directory by TF."
  file_permission      = "0644"
  directory_permission = "0777"

  # https://github.com/hashicorp/terraform-provider-local/issues/366
  provisioner "local-exec" {
    command = "mkdir -p ${local.host_storage_directory} && chmod 1777 ${local.host_storage_directory}"
  }
}
