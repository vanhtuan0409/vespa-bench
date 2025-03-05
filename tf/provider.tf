terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.88.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  arm_ami       = "ami-0f37c4a1ba152af46"
  deploy_dir    = "/opt/anduin/vespa"
  deploy_docker = "${local.deploy_dir}/docker-compose.yaml"
  data_dir      = "/data/vespa"
}
