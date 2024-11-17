# Create jobs persistent directory
resource "linux_folder" "jobs_data" {
  path        = local.host_data_directory
  owner       = "root:root"
  permissions = 705 # 2755 in octal
}
