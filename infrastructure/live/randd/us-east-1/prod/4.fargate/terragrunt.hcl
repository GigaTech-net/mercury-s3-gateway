locals {
  # automatically load global variables
  global_vars = read_terragrunt_config(find_in_parent_folders("global_vars.hcl", "ignore"), {inputs = {}})
  
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl", "ignore"), {inputs = {}})

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl", "ignore"), {inputs = {}})

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl", "ignore"), {inputs = {}})

  # Extract out common variables for reuse
  account_name        = local.account_vars.locals.account_name
  account_id          = local.account_vars.locals.aws_account_id
  aws_profile         = local.account_vars.locals.aws_profile
  costcenter          = local.account_vars.locals.costcenter
  aws_region          = local.region_vars.locals.aws_region

  fhir_domain_prod    = local.global_vars.locals.fhir_domain
  pm_gateway_domain   = local.global_vars.locals.pm_gateway_domain
  fhir_domain_dev     = local.global_vars.locals.fhir_domain_dev

  env                 = local.environment_vars.locals.environment
  prefix              = local.global_vars.locals.prefix
  createdby           = local.global_vars.locals.createdby
  createdbytag        = local.global_vars.locals.createdbytag
  costcentertag       = local.global_vars.locals.costcentertag
  
  appname             = local.account_vars.locals.appname
  appnametag          = local.global_vars.locals.appnametag
  envnametag          = local.global_vars.locals.envnametag
}

terraform {
  source = "git::git@github.com:GigaTech-net/terraform-AWS-gt-fargate-app.git?ref=0.0.36"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders("root.hcl")
}

dependency "shared-data" {
  config_path = "../1.shared-infra"
}

dependency "ecr" {
  config_path = "../3.ecr"
}

inputs = {
  prefix                = "${local.appname}-${local.env}"
  vpc_id                = dependency.shared-data.outputs.vpc-alb.vpc.app_vpc.id
  ecs_cluster_name      = dependency.shared-data.outputs.vpc-alb.ecs_cluster.name
  pub_subnet_1_id       = dependency.shared-data.outputs.vpc-alb.subnets.public_subnets[0].id
  pub_subnet_2_id       = dependency.shared-data.outputs.vpc-alb.subnets.public_subnets[1].id
  alb_listener_arn      = dependency.shared-data.outputs.vpc-alb.alb-listeners.ecs-listener.arn
  ecr_repo_url          = dependency.ecr.outputs.repository_url
  ecr_repo_tag          = "main"
  domain_name           = local.pm_gateway_domain
  docker_container_port = 80
  region                = local.aws_region
  userpoolid            = ""
  userpoolappclientid   = ""
  desired_task_number   = 1
  memory                = 1024
  cpu                   = 512
  env                   = local.env
  health_check_grace_period_seconds = 120
  path_patterns         = [
    "/emp-dev/*",
    "/emp-dev",
    "/bddash-dev/*",
    "/bddash-dev"
  ]

  tags = {
    "${local.createdbytag}" = "${local.createdby}",
    "${local.costcentertag}" = "${local.costcenter}",
    "${local.appnametag}" = "${local.appname}",
    "${local.envnametag}" = "${local.env}"
  }
}