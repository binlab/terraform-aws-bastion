locals {
  name_tmpl             = format("%s%s-%s", var.prefix, var.stack, "%s")
  ca_ssh_public_keys    = length(var.ca_ssh_public_keys) == 0 ? false : true
  ca_tls_public_keys    = length(var.ca_tls_public_keys) == 0 ? false : true
  ec2_ssh_auth_keys     = length(var.ec2_ssh_auth_keys) == 0 ? false : true
  bastion_ssh_auth_keys = length(var.bastion_ssh_auth_keys) == 0 ? false : true

  tags = merge({
    Description = var.description
    ManagedBy   = "Terraform"
    Terraform   = true
    Stack       = var.stack
    Environment = "stage"
    Service     = "Bastion Tower"
    Name        = format("%s%s", var.prefix, var.stack)
    Version     = var.docker_tag
  }, var.tags)
}
