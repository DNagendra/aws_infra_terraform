variable "vpc_id" {
  type        = string
  description = "VPC Id to associate with rds"
}
variable "identifier" {}
variable "db_instance" {}
variable "allocated_storage"  {} 
variable "storage_type"  {}       
variable "engine"    {}         
variable "engine_version"  {}   
variable "instance_class"  {}    
variable "name"      {}  
variable "username"   {}       
variable "password"   {}        
variable "parameter_group_name" {}
variable "publicly_accessible"  {}
variable "subnet_ids" {}
variable "backup_retention_period" {}
#variable "db_subnet_group_name" {}

variable "tags" {
  description = "Tags to set on the bucket."
  type = map(string)
  default = {}
}