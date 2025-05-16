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
  source = "git::git@github.com:lgallard/terraform-aws-ecr?ref=0.3.2" 
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  name = "${local.appname}",
  tags = {
    "${local.createdbytag}" = "${local.createdby}",
    "${local.costcentertag}" = "${local.costcenter}",
    "${local.appnametag}" = "${local.appname}",
    "${local.envnametag}" = "${local.env}"
  }
}