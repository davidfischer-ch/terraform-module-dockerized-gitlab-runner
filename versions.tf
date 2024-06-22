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

    system = {
      source  = "neuspaces/system"
      version = ">= 0.5.0"
    }
  }
}
