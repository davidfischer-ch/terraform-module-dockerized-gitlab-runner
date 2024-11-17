# Create jobs persistent directory

resource "local_file" "jobs_data_touch" {
  filename             = "local.host_data_directory/.touch"
  content              = "Used to create directory by TF."
  directory_permission = "0755"

  # https://github.com/hashicorp/terraform-provider-local/issues/366
  provisioner "local-exec" {
    command = "mkdir -p ${local.host_data_directory} && chmod g+s ${local.host_data_directory}"
  }
}
