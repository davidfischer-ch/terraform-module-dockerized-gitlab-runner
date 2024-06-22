resource "system_folder" "builds" {
  path = "${var.data_directory}/builds"
  uid  = 0
  gid  = 0
  mode = "755"
}

resource "system_folder" "cache" {
  path = "${var.data_directory}/cache"
  uid  = 0
  gid  = 0
  mode = "755"
}

resource "system_folder" "config" {
  path = "${var.data_directory}/config"
  uid  = 0
  gid  = 0
  mode = "755"
}

resource "system_folder" "scripts" {
  path = "${var.data_directory}/scripts"
  uid  = 0
  gid  = 0
  mode = "755"
}
