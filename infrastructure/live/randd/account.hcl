locals {
  account_name   = "randd"
  aws_account_id = "939257149235"
  aws_profile    = "GT_CORE_ADMIN"
  role_to_assume = "adminAssumeRole"
   
  # tags specific to this account
  costcenter = "r and d"
  appname = "pms3gw"
}