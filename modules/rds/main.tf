
resource "aws_db_subnet_group" "rds-db-subnet" {
  name = "${var.name}-subnet-name"
  subnet_ids = var.subnet_ids
  #vpc_id = var.vpc_id
}

resource "aws_security_group" "rds-security-group" {
  name = "${var.name}-sg-name"
  vpc_id = var.vpc_id
}

resource "aws_db_instance" "rds-db-resource" {
  identifier = var.identifier
  instance_class = var.instance_class
  engine = var.engine
  engine_version = var.engine_version
  multi_az = true
  storage_type = var.storage_type
  allocated_storage = var.allocated_storage
  name = var.name
  username = var.username
  password = var.password
  apply_immediately = true
  skip_final_snapshot  = true
  backup_retention_period = var.backup_retention_period
  backup_window = "09:46-10:16"
  db_subnet_group_name = aws_db_subnet_group.rds-db-subnet.name
  vpc_security_group_ids = ["${aws_security_group.rds-security-group.id}"]
  tags = var.tags
}

resource "aws_security_group_rule" "rds-security-group-rule" {
  from_port = 3306
  protocol = "tcp"
  security_group_id = aws_security_group.rds-security-group.id
  to_port = 3306
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_rule" {
  from_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.rds-security-group.id
  to_port = 0
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}