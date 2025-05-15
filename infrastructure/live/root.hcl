locals {
  # automatically load global variables
  global_vars = read_terragrunt_config(find_in_parent_folders("global_vars.hcl", "ignore"), {inputs = {}})

  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl", "ignore"), {inputs = {}})

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl", "ignore"), {inputs = {}})

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl", "ignore"), {inputs = {}})

  # Extract the variables we need for easy access
  account_name           = local.account_vars.locals.account_name
  account_id             = local.account_vars.locals.aws_account_id
  appname                = local.account_vars.locals.appname
  aws_profile            = local.account_vars.locals.aws_profile
  costcenter             = local.account_vars.locals.costcenter
  role_to_assume         = local.account_vars.locals.role_to_assume
  aws_region             = local.region_vars.locals.aws_region
  prefix                 = local.global_vars.locals.prefix
  createdby              = local.global_vars.locals.createdby
  createdbytag           = local.global_vars.locals.createdbytag
  costcentertag          = local.global_vars.locals.costcentertag
  s3_backend_bucket_name = "${local.prefix}${local.account_name}-mercury-${local.appname}-terragrunt-terraform-state"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region  = "${local.aws_region}"
  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${local.account_id}"]
  assume_role {
   role_arn = "arn:aws:iam::${local.account_id}:role/${local.role_to_assume}"
  }
}
EOF
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    encrypt = true
    bucket = local.s3_backend_bucket_name
    key    = "${path_relative_to_include()}/terraform.tfstate"
    region = local.aws_region
    dynamodb_table = "terraform-lock"
    s3_bucket_tags = {
      name  = "Terraform state storage"
      "${local.createdbytag}" = local.createdby
      "${local.costcentertag}" = local.costcenter
    }
    dynamodb_table_tags = {
      name  = "Terraform lock table"
      "${local.createdbytag}" = local.createdby
      "${local.costcentertag}" = local.costcenter
    }
  }
}

inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
  local.environment_vars.locals,
)