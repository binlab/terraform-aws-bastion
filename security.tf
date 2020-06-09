resource "aws_security_group" "bastion" {
  name        = format(local.name_tmpl, "bastion")
  description = "Allow Bastion Inbound Traffic"
  vpc_id      = var.vpc_id

  ingress {
    description     = "EC2 SSH Port"
    from_port       = var.ec2_ssh_port
    to_port         = var.ec2_ssh_port
    protocol        = "tcp"
    cidr_blocks     = var.ec2_ssh_cidr
  }

  ingress {
    description     = "Bastion SSH port"
    from_port       = var.bastion_ssh_port
    to_port         = var.bastion_ssh_port
    protocol        = "tcp"
    cidr_blocks     = var.bastion_ssh_cidr
  }

  egress {
    description = "Allow All Outbound Traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Description = "Allow ALB Inbound Traffic"
    Name        = format(local.name_tmpl, "bastion")
  })
}
