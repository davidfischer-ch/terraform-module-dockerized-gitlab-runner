terraform {
  required_version = ">= 1.6"

  required_providers {
    # https://github.com/kreuzwerker/terraform-provider-docker/tags
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 3.0.2"
    }

    # https://github.com/gitlabhq/terraform-provider-gitlab/tags
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = ">= 16.8.1"
    }

    # https://github.com/hashicorp/terraform-provider-local/tags
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4.1"
    }
  }
}

provider "gitlab" {
  base_url = var.gitlab_url
}
