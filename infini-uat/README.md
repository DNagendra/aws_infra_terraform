# denzi-tenant - QA environment

Module to orchestrate various modules to build a single tenant. A separate folder should be created per tenant similar to this one to maintain the state of it. 

Provide values for below local variables to spin up the new infrastructure for DEV environment
Below values are for reference only.

  tenant_name             = "denzi"
  environment             = "qa"
  cidr_block              = "16.255.0.0/16"
  db_username             = "denziuat"
  db_password             = "tenant123$"
  db_identifier           = "denzi-qa-instance"
  db_instance             = "mysql-denzi-qa-instance"
  tf_remote_state_bucket  = "denzi-uat-remote-state"
  region                  = "us-east-2"

  Also update the new tf bucket name at the bottom of the script with value of "tf_remote_state_bucket"
  terraform {
  backend "s3" {
    bucket = "denzi-uat-remote-state"
