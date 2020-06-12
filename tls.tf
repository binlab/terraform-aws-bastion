resource tls_private_key "ec2_ssh" {
  count = local.ec2_ssh_auth_keys ? 0 : 1

  algorithm   = var.ec2_ssh_algorithm
  rsa_bits    = var.ec2_ssh_rsa_bits
  ecdsa_curve = var.ec2_ssh_ecdsa_curve
}
