terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80"
    }
  }
  # Bucket and region come from backend.hcl: terraform init -backend-config=backend.hcl
  backend "s3" {
    key          = "envs/dev/terraform.tfstate"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = { Project = "pulse-infra", Environment = "dev", ManagedBy = "terraform" }
  }
}

locals {
  name = "pulse-forecast-dev"
}

module "network" {
  source = "../../modules/network"
  name   = local.name
}

module "ecr" {
  source = "../../modules/ecr"
  name   = "pulse-forecast"
}

module "service" {
  source     = "../../modules/ecs-service"
  name       = local.name
  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.public_subnet_ids
  image      = "${module.ecr.repository_url}:${var.image_tag}"
  use_spot   = var.use_spot
  min_count  = 1
  max_count  = 2
  environment = {
    PULSE_ARTIFACTS = "/app/artifacts"
  }
}
