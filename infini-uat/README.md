# infini-tenant - QA environment

Module to orchestrate various modules to build a single tenant. A separate folder should be created per tenant similar to this one to maintain the state of it. 

Provide values for below local variables to spin up the new infrastructure for DEV environment
Below values are for reference only.

  tenant_name             = "infini"
  environment             = "qa"
  cidr_block              = "16.255.0.0/16"
  db_username             = "infiniuat"
  db_password             = "tenant123$"
  db_identifier           = "infini-qa-instance"
  db_instance             = "mysql-infini-qa-instance"
  tf_remote_state_bucket  = "infini-uat-remote-state"
  region                  = "us-east-2"

  Also update the new tf bucket name at the bottom of the script with value of "tf_remote_state_bucket"
  terraform {
  backend "s3" {
    bucket = "infini-uat-remote-state"
