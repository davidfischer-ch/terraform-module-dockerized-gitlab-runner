terraform {
  required_version = ">= 1.3"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 2.23.0"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.2.3"
    }
  }
}
