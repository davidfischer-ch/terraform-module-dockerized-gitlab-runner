terraform {
  required_version = ">= 1.6"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 2.23.0"
    }

    gitlab = {
      source  = "gitlabhq/gitlab"
      version = ">= 3.20.0"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.2.3"
    }
  }
}
