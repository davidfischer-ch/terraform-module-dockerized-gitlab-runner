terraform {
  required_version = ">= 1.6"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 3.0.2"
    }

    gitlab = {
      source  = "gitlabhq/gitlab"
      version = ">= 16.8.1"
    }

    linux = {
      # https://github.com/mavidser/terraform-provider-linux/tags
      source  = "mavidser/linux"
      version = ">= 1.0.2"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.4.1"
    }
  }
}
