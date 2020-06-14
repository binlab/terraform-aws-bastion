variable "stack" {
  description = <<-EOT
    Stack name and tag "Name", can be a project name.
    Format of "Name" tag "<prefix>-<stack>-<resource>"
  EOT
  type        = string
  default     = "binlab"
}

variable "prefix" {
  description = <<-EOT
    Prefix of a tag "Name", can be a namespace.
    Format of "Name" tag "<prefix>-<stack>-<resource>"
  EOT
  type        = string
  default     = "tf-"
}

variable "description" {
  description = <<-EOT
    Description for Tags in all resources.
  EOT
  type        = string
  default     = "Bastion Tower"
}

variable "bastion_ssh_port" {
  description = <<-EOT
    Bastion SSH port open to the users connect. May be open to the 
    whole world so try to not use the standard port (22). Changing 
    this value might request redeploy an instance (need to reconfigure 
    SSH config)
  EOT
  type        = number
  default     = 10022
}

variable "bastion_ssh_cidr" {
  description = <<-EOT
    Allowed CIDRs to connect to a cluster on ALB endpoint
  EOT
  type        = list(string)
  default     = ["0.0.0.0/32"]
}

variable "ec2_ssh_port" {
  description = <<-EOT
    EC2 instance SSH port. Generally not needed to use. If need, you 
    can connect to the instance via Bastion itself. Sometimes need 
    just for debugging.
  EOT
  type        = number
  default     = 22
}

variable "ec2_ssh_cidr" {
  description = <<-EOT
    List of CIDR/IP which will be allowed to connect to EC2 instances 
    on SSH port. Generally not needed to use. If need, you can connect 
    to the instance via bastion  Sometimes need just for debugging. 
    By default disallowed all IPs. Allow it with the caution.
  EOT
  type        = list(string)
  default     = ["0.0.0.0/32"]
}

variable "security_groups" {
  description = <<-EOT
    List of external Security Groups for assigning to EC2 instances. 
    Useful for custom configuration with another infrastructure to which 
    the Bastion connected.
  EOT
  type        = list(string)
  default     = []
}

variable "ami_vendor" {
  description = <<-EOT
    AMI filter for OS vendor [coreos/flatcar]
  EOT
  type        = string
  default     = "flatcar"
}

variable "ami_channel" {
  description = <<-EOT
    AMI filter for OS channel [stable/edge/beta/etc]
  EOT
  type        = string
  default     = "stable"
}

variable "ami_image" {
  description = <<-EOT
    Specific AMI image ID in current Avalability Zone e.g. [ami-123456]
    If provided nodes will be run on it, for cases when image built by 
    Packer if set it will disable search images by "ami_vendor" and 
    "ami_channel". Note: Instance OS should support CoreOS Ignition 
    provisioning
  EOT
  type        = string
  default     = ""
}

variable "availability_zone" {
  description = <<-EOT
    Index of Availability Zone to deploy, starting from 0. 
    For example: "us-east-1a"=0, "us-east-1b"=1, "us-east-1c"=2 ...
  EOT
  type        = number
  default     = 0
}

variable "vpc_id" {
  description = <<-EOT
    External VPC ID which Bastion module assigned to
  EOT
  type        = string
}

variable "vpc_subnet_id" {
  description = <<-EOT
    External VPC Subnet ID which Bastion module assigned to
  EOT
  type        = string
}

variable "instance_type" {
  description = <<-EOT
    Type of instance e.g. [t3.small]
  EOT
  type        = string
  default     = "t3.small"
}

variable "monitoring" {
  description = <<-EOT
    CloudWatch detailed monitoring [true/false]
  EOT
  type        = bool
  default     = false
}

variable "volume_size" {
  description = <<-EOT
    Node (Root) volume block device Size (GB) e.g. [8]
  EOT
  type        = number
  default     = 8
}

variable "volume_type" {
  description = <<-EOT
    Node (Root) volume block Device Type e.g. [gp2]
  EOT
  type        = string
  default     = "gp2"
}

variable "cpu_credits" {
  description = <<-EOT
    The credit option for CPU usage [unlimited/standard]
  EOT
  type        = string
  default     = "standard"
}

variable "bastion_ssh_auth_keys" {
  description = <<-EOT
    List of SSH authorized keys assigned to "bastion" user
    By default is ["false"] which means disabled pass external keys and 
    dont generate 
  EOT
  type        = list(string)
  default     = []
}

variable "ec2_ssh_auth_keys" {
  description = <<-EOT
    List of SSH authorized keys assigned to "Core" user (sudo user)
  EOT
  type        = list(string)
  default     = []
}

variable "ec2_ssh_algorithm" {
  description = <<-EOT
    The name of the algorithm to use for the key. 
    Currently-supported values are "RSA" and "ECDSA".
    Applying Only if variable "ec2_ssh_auth_keys" not set.
  EOT
  type        = string
  default     = "RSA"
}

variable "ec2_ssh_rsa_bits" {
  description = <<-EOT
    When algorithm is "RSA", the size of the generated RSA key in bits. 
    Defaults to 4096.
    Applying Only if variable "ec2_ssh_auth_keys" not set.
  EOT
  type        = number
  default     = 4096
}

variable "ec2_ssh_ecdsa_curve" {
  description = <<-EOT
    When algorithm is "ECDSA", the name of the elliptic curve to use. 
    May be any one of "P224", "P256", "P384" or "P521", with "P256" as 
    the default.
    Applying Only if variable "ec2_ssh_auth_keys" not set.
  EOT
  type        = string
  default     = "P256"
}

variable "ca_ssh_public_keys" {
  description = <<-EOT
    List of SSH Certificate Authority public keys. Specifies a public 
    keys of certificate authorities that are trusted to sign 
    user certificates for authentication. More: 
    https://man.openbsd.org/sshd_config#TrustedUserCAKeys
  EOT
  type        = list(string)
  default     = []
}

variable "ssh_core_principals" {
  description = <<-EOT
    List of SSH authorized principals for user "Admin" when SSH login 
    configured via Certificate Authority ("ca_ssh_public_key" is set) 
    More: https://man.openbsd.org/sshd_config#AuthorizedPrincipalsFile
  EOT
  type        = list(string)
  default     = ["sudo"]
}

variable "ssh_admin_principals" {
  description = <<-EOT
    List of SSH authorized principals for user "Core" when SSH login 
    configured via Certificate Authority ("ca_ssh_public_key" is set)
    https://man.openbsd.org/sshd_config#AuthorizedPrincipalsFile
  EOT
  type        = list(string)
  default     = ["tower"]
}

variable "ssh_bastion_principals" {
  description = <<-EOT
    List of SSH authorized principals for "Bastion" user when SSH login 
    configured via Certificate Authority ("ca_ssh_public_key" is set)
    https://man.openbsd.org/sshd_config#AuthorizedPrincipalsFile
  EOT
  type        = list(string)
  default     = ["bastion"]
}

variable "ca_tls_public_keys" {
  description = <<-EOT
    List of custom Certificate Authority public keys. Used when need 
    to connect from Vault to resources with a self-signed certificate
  EOT
  type        = list(string)
  default     = []
}

variable "tags" {
  description = <<-EOT
    Map of tags assigned to each or created resources in AWS. 
    By default, used predefined described map in a file "locals.tf".
    Each of them can be overwritten here separately.
  EOT
  type        = map(string)
  default     = {}
}

variable "docker_repo" {
  description = <<-EOT
    Vault Docker repository URI
  EOT
  type        = string
  default     = "docker://binlab/bastion"
}

variable "docker_tag" {
  description = <<-EOT
    Vault Docker image version tag
  EOT
  type        = string
  default     = "1.2.0"
}
