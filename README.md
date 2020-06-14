# Terraform AWS Bastion host based on [Docker Bastion](https://github.com/binlab/docker-bastion)

<p align="center">
  <a href="https://github.com/binlab/terraform-aws-bastion/blob/LICENSE"><img alt="License" src="https://img.shields.io/github/license/binlab/terraform-aws-bastion?logo=github"></a>
  <a href="https://github.com/binlab/terraform-aws-bastion/tags"><img alt="GitHub tag" src="https://img.shields.io/github/v/tag/binlab/terraform-aws-bastion?logo=github"></a>
  <a href="https://github.com/binlab/terraform-aws-bastion/releases"><img alt="GitHub release" src="https://img.shields.io/github/v/release/binlab/terraform-aws-bastion?logo=github"></a>
  <a href="https://github.com/binlab/terraform-aws-bastion/commits"><img alt="Last Commit" src="https://img.shields.io/github/last-commit/binlab/terraform-aws-bastion?logo=github"></a>
  <a href="https://github.com/binlab/terraform-aws-bastion/commits"><img alt="GitHub commit activity" src="https://img.shields.io/github/commit-activity/m/binlab/terraform-aws-bastion?logo=github"></a>
</p>
<p align="center">
  <img alt="languages Count" src="https://img.shields.io/github/languages/count/binlab/terraform-aws-bastion">
  <img alt="Languages Top" src="https://img.shields.io/github/languages/top/binlab/terraform-aws-bastion">
  <img alt="Code Size" src="https://img.shields.io/github/languages/code-size/binlab/terraform-aws-bastion">
  <img alt="Repo Size" src="https://img.shields.io/github/repo-size/binlab/terraform-aws-bastion">
</p>

A **Bastion** host is providing isolation between not safe external world and private VPC for infrastructure. That's what Amazon himself writes about it:

>Including bastion hosts in your VPC environment enables you to securely connect to your Linux instances without exposing your environment to the Internet. After you set up your bastion hosts, you can access the other instances in your VPC through Secure Shell (SSH) connections on Linux. Bastion hosts are also configured with security groups to provide fine-grained ingress control. [source](https://docs.aws.amazon.com/quickstart/latest/linux-bastion/architecture.html)


## Key features:

- Can be run with low consumption of costs or even just on *AWS Free Tier*
- No need additional provisioning tools like **Ansible**, **Chief** of **Puppet**, all based on clear **Terraform**
- The module is almost an independent with zero-external resources dependencies except for `VPC ID` and `Subnets Id` which **Bastion** module assigned to
- Provisioning based on **CoreOS ignitions** so very fast, declarative and predictable 
- Providing a two-mode of work: with using an `SSH` demon on the host machine or more secure - with additional isolation by running `SSH` **Bastion** in `Docker` container (most recommended)
- Possible to upgrade or downgrade a **Bastion** `sshd` (SSH Server) version (only when used **Bastion** `SSH` Docker version)
- Can be set custom Docker image and version for `SSH` (with Docker version only) by default is using this one https://github.com/binlab/docker-bastion
- Optional generation `SSH` pair for host, by default (**RSA-4096**) (not recommended, better to provisioning external `SSH` public key)
- Access to **Bastion** by `SSH` also can by provisioning **Root CA** *certificate* and *principals*
- Custom `SSH Authorized Principals` can be configured for bought modes: Host and Docker. More https://man.openbsd.org/sshd_config#AuthorizedPrincipalsFile
- Provided assigning external own **Root CA** for cases when **Bastion** need secure communicate with internal infrastructure


## AWS Permissions

For deploying you need a list of permissions. For beginners might be difficult to set up minimal need permissions, so here the list wildcard for main actions.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "BastionProvisioning",
      "Effect": "Allow",
      "Action": [
        "ec2:*"
      ],
      "Resource": "*"
    }
  ]
}
```

## Usage

The module can be deployed with almost default values of variables. For more details of the default values looking [here](#inputs)

```hcl
...

module "bastion" {
  source = "github.com/binlab/terraform-aws-bastion?ref=v0.1.0"

  vpc_id                = vpc.vpc_id
  vpc_subnet_id         = vpc.public_subnets[0]
  ec2_ssh_cidr          = ["0.0.0.0/0"]
  bastion_ssh_cidr      = ["0.0.0.0/0"]
  ec2_ssh_auth_keys     = [file("~/.ssh/id_rsa.pub")]
  bastion_ssh_auth_keys = [file("~/.ssh/id_rsa.pub")]
}

output "ec2_ssh_private_key" {
  value = module.bastion.ec2_ssh_private_key
}

output "bastion_public_ip" {
  value = module.bastion.public_ip
}

output "bastion_public_dns" {
  value = module.bastion.public_dns
}
```

*Then run:*

```shell
$ terraform init
$ terraform apply
```

*After deploying the process you should see:*

```shell
...
bastion_public_dns = ec2-12-34-56-78.us-east-1.compute.amazonaws.com
bastion_public_ip = 12.34.56.78
ec2_ssh_private_key =
$
```

\* `ec2_ssh_private_key` is empty because we defined own key

## TODO

- [ ] Add examples of use with different cases
- [ ] Hosted module on [Terraform Registry](https://registry.terraform.io) - [#11](https://github.com/binlab/terraform-aws-bastion/issues/11)
- [ ] Add validation of input data in [variables.tf](variables.tf) 
- [ ] Add support **Fedora CoreOS** as [announced](https://coreos.com/os/docs/latest/cloud-config-deprecated.html) **CoreOS Container Linux** will reach its end of life on **May 26, 2020** and will no longer receive updates.
- [ ] Replace creating **EC2 instances** to an autoscaling group
- [ ] Add support of **OpenStack (OS)** Terraform module
- [ ] Add support of **Google Cloud Platform (GCP)** Terraform module
- [ ] Add support of **Microsoft Azure** Terraform module
- [ ] Add support of **AliCloud** Terraform module
- [ ] Add support of **Oracle Cloud (OCI)** Terraform module

## Limitations

- Requirements block and [versions.tf](versions.tf) may not accurately display a real minimum version of providers. A declared versions ware just an installed in the time of development and testing of the module and can give guaranties of working with this or higher version. If you use older versions of modules for some reason and can give some guarantees of working with it, please create an issue for downscaling some version to minimal needed.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| aws | >= 2.53.0 |
| ignition | >= 1.2.1 |
| tls | >= 2.1.1 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.53.0 |
| ignition | >= 1.2.1 |
| tls | >= 2.1.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami\_channel | AMI filter for OS channel [stable/edge/beta/etc] | `string` | `"stable"` | no |
| ami\_image | Specific AMI image ID in current Avalability Zone e.g. [ami-123456]<br>If provided nodes will be run on it, for cases when image built by <br>Packer if set it will disable search images by "ami\_vendor" and <br>"ami\_channel". Note: Instance OS should support CoreOS Ignition <br>provisioning | `string` | `""` | no |
| ami\_vendor | AMI filter for OS vendor [coreos/flatcar] | `string` | `"flatcar"` | no |
| availability\_zone | Index of Availability Zone to deploy, starting from 0. <br>For example: "us-east-1a"=0, "us-east-1b"=1, "us-east-1c"=2 ... | `number` | `0` | no |
| bastion\_ssh\_auth\_keys | List of SSH authorized keys assigned to "bastion" user<br>By default is ["false"] which means disabled pass external keys and <br>dont generate | `list(string)` | `[]` | no |
| bastion\_ssh\_cidr | Allowed CIDRs to connect to a cluster on ALB endpoint | `list(string)` | <pre>[<br>  "0.0.0.0/32"<br>]</pre> | no |
| bastion\_ssh\_port | Bastion SSH port open to the users connect. May be open to the <br>whole world so try to not use the standard port (22). Changing <br>this value might request redeploy an instance (need to reconfigure <br>SSH config) | `number` | `10022` | no |
| ca\_ssh\_public\_keys | List of SSH Certificate Authority public keys. Specifies a public <br>keys of certificate authorities that are trusted to sign <br>user certificates for authentication. More: <br>https://man.openbsd.org/sshd_config#TrustedUserCAKeys | `list(string)` | `[]` | no |
| ca\_tls\_public\_keys | List of custom Certificate Authority public keys. Used when need <br>to connect from Vault to resources with a self-signed certificate | `list(string)` | `[]` | no |
| cpu\_credits | The credit option for CPU usage [unlimited/standard] | `string` | `"standard"` | no |
| description | Description for Tags in all resources. | `string` | `"Bastion Tower"` | no |
| docker\_repo | Vault Docker repository URI | `string` | `"docker://binlab/bastion"` | no |
| docker\_tag | Vault Docker image version tag | `string` | `"1.2.0"` | no |
| ec2\_ssh\_algorithm | The name of the algorithm to use for the key. <br>Currently-supported values are "RSA" and "ECDSA".<br>Applying Only if variable "ec2\_ssh\_auth\_keys" not set. | `string` | `"RSA"` | no |
| ec2\_ssh\_auth\_keys | List of SSH authorized keys assigned to "Core" user (sudo user) | `list(string)` | `[]` | no |
| ec2\_ssh\_cidr | List of CIDR/IP which will be allowed to connect to EC2 instances <br>on SSH port. Generally not needed to use. If need, you can connect <br>to the instance via bastion  Sometimes need just for debugging. <br>By default disallowed all IPs. Allow it with the caution. | `list(string)` | <pre>[<br>  "0.0.0.0/32"<br>]</pre> | no |
| ec2\_ssh\_ecdsa\_curve | When algorithm is "ECDSA", the name of the elliptic curve to use. <br>May be any one of "P224", "P256", "P384" or "P521", with "P256" as <br>the default.<br>Applying Only if variable "ec2\_ssh\_auth\_keys" not set. | `string` | `"P256"` | no |
| ec2\_ssh\_port | EC2 instance SSH port. Generally not needed to use. If need, you <br>can connect to the instance via Bastion itself. Sometimes need <br>just for debugging. | `number` | `22` | no |
| ec2\_ssh\_rsa\_bits | When algorithm is "RSA", the size of the generated RSA key in bits. <br>Defaults to 4096.<br>Applying Only if variable "ec2\_ssh\_auth\_keys" not set. | `number` | `4096` | no |
| instance\_type | Type of instance e.g. [t3.small] | `string` | `"t3.small"` | no |
| monitoring | CloudWatch detailed monitoring [true/false] | `bool` | `false` | no |
| prefix | Prefix of a tag "Name", can be a namespace.<br>Format of "Name" tag "<prefix>-<stack>-<resource>" | `string` | `"tf-"` | no |
| security\_groups | List of external Security Groups for assigning to EC2 instances. <br>Useful for custom configuration with another infrastructure to which <br>the Bastion connected. | `list(string)` | `[]` | no |
| ssh\_admin\_principals | List of SSH authorized principals for user "Core" when SSH login <br>configured via Certificate Authority ("ca\_ssh\_public\_key" is set)<br>https://man.openbsd.org/sshd_config#AuthorizedPrincipalsFile | `list(string)` | <pre>[<br>  "tower"<br>]</pre> | no |
| ssh\_bastion\_principals | List of SSH authorized principals for "Bastion" user when SSH login <br>configured via Certificate Authority ("ca\_ssh\_public\_key" is set)<br>https://man.openbsd.org/sshd_config#AuthorizedPrincipalsFile | `list(string)` | <pre>[<br>  "bastion"<br>]</pre> | no |
| ssh\_core\_principals | List of SSH authorized principals for user "Admin" when SSH login <br>configured via Certificate Authority ("ca\_ssh\_public\_key" is set) <br>More: https://man.openbsd.org/sshd_config#AuthorizedPrincipalsFile | `list(string)` | <pre>[<br>  "sudo"<br>]</pre> | no |
| stack | Stack name and tag "Name", can be a project name.<br>Format of "Name" tag "<prefix>-<stack>-<resource>" | `string` | `"binlab"` | no |
| tags | Map of tags assigned to each or created resources in AWS. <br>By default, used predefined described map in a file "locals.tf".<br>Each of them can be overwritten here separately. | `map(string)` | `{}` | no |
| volume\_size | Node (Root) volume block device Size (GB) e.g. [8] | `number` | `8` | no |
| volume\_type | Node (Root) volume block Device Type e.g. [gp2] | `string` | `"gp2"` | no |
| vpc\_id | External VPC ID which Bastion module assigned to | `string` | n/a | yes |
| vpc\_subnet\_id | External VPC Subnet ID which Bastion module assigned to | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| ec2\_ssh\_private\_key | SSH private key which generated by module and its public key <br>part assigned to each of nodes. Don't recommended do this as <br>a private key will be kept open and stored in a state file. <br>Instead of this set variable "ssh\_authorized\_keys". Please note, <br>if "ssh\_authorized\_keys" set "ssh\_private\_key" return empty output |
| public\_dns | Public DNS name associated with an instance by AWS<br>Can be assigned to a domain name by CNAME record |
| public\_ip | Public IP associated with an instance by AWS<br>Can be assigned to a domain name by "A record" |
| security\_group\_id | Security Group ID which created within the module<br>Useful for assigning to other Security Groups as a source |
