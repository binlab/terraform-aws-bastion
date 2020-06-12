output "public_ip" {
  description = <<-EOT
    Public IP associated with an instance by AWS
    Can be assigned to a domain name by "A record"
  EOT
  value       = aws_instance.bastion.public_ip
}

output "public_dns" {
  description = <<-EOT
    Public DNS name associated with an instance by AWS
    Can be assigned to a domain name by CNAME record
  EOT
  value       = aws_instance.bastion.public_dns
}

output "ec2_ssh_private_key" {
  description = <<-EOT
  TODO
    SSH private key which generated by module and its public key 
    part assigned to each of nodes. Don't recommended do this as 
    a private key will be kept open and stored in a state file. 
    Instead of this set variable "ssh_authorized_keys". Please note, 
    if "ssh_authorized_keys" set "ssh_private_key" return empty output
  EOT
  value = (
    local.ec2_ssh_auth_keys ? "" : tls_private_key.ec2_ssh[0].private_key_pem
  )
}

output "security_group_id" {
  description = <<-EOT
    Security Group ID which created within the module
    Useful for assigning to other Security Groups as a source
  EOT
  value       = aws_security_group.bastion.id
}
