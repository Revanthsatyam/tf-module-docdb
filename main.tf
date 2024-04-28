resource "aws_docdb_subnet_group" "main" {
  name       = "${local.name_prefix}-subnet"
  subnet_ids = var.subnet_ids
  tags       = merge(local.tags, { Name = "${local.name_prefix}-subnet" })
}

resource "aws_security_group" "main" {
  name        = "${local.name_prefix}-sg"
  description = "${local.name_prefix}-sg"
  vpc_id      = var.vpc_id
  tags        = merge(local.tags, { Name = "${local.name_prefix}-sg" })

  ingress {
    description = "DOCDB"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = var.sg_ingress_cidr
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_docdb_cluster" "main" {
  cluster_identifier      = "${local.name_prefix}-cluster"
  engine                  = var.engine
  master_username         = "foo"
  master_password         = "mustbeeightchars"
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  skip_final_snapshot     = var.skip_final_snapshot
  vpc_security_group_ids  = [aws_security_group.main.id]
  db_subnet_group_name    = aws_docdb_subnet_group.main.id
}

