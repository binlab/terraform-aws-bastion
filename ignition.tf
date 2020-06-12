data ignition_user "core" {
  name = "core"
  uid  = 500
  ssh_authorized_keys = (
    local.ec2_ssh_auth_keys ? var.ec2_ssh_auth_keys : [
      tls_private_key.ec2_ssh[0].public_key_openssh
    ]
  )
}

data ignition_user "admin" {
  count = local.ca_ssh_public_keys ? 1 : 0

  name = "admin"
  uid  = 1000
}

data ignition_file "sshd_config" {
  count = local.ca_ssh_public_keys ? 1 : 0

  filesystem = "root"
  path       = "/etc/ssh/sshd_config"
  mode       = 384 ### 0600
  uid        = 0
  gid        = 0
  content {
    mime    = "text/plain"
    content = <<-EOT
      Port ${var.ec2_ssh_port} 
      UsePrivilegeSeparation sandbox
      ClientAliveInterval 180
      UseDNS no
      UsePAM yes
      PermitRootLogin no
      AllowUsers core admin
      AuthenticationMethods publickey
      TrustedUserCAKeys /etc/ssh/ssh_ca_rsa_keys.pub
      AuthorizedPrincipalsFile /etc/ssh/auth_principals/%u
    EOT
  }
}

data ignition_file "auth_principals_core" {
  count = local.ca_ssh_public_keys ? 1 : 0

  filesystem = "root"
  path       = "/etc/ssh/auth_principals/core"
  mode       = 420 ### 0644
  uid        = 0
  gid        = 0
  content {
    mime    = "text/plain"
    content = join("\n", var.ssh_core_principals)
  }
}

data ignition_file "auth_principals_admin" {
  count = local.ca_ssh_public_keys ? 1 : 0

  filesystem = "root"
  path       = "/etc/ssh/auth_principals/admin"
  mode       = 420 ### 0644
  uid        = 0
  gid        = 0
  content {
    mime    = "text/plain"
    content = join("\n", var.ssh_admin_principals)
  }
}

data ignition_file "ca_ssh_public_keys" {
  count = local.ca_ssh_public_keys ? 1 : 0

  filesystem = "root"
  path       = "/etc/ssh/ssh_ca_rsa_keys.pub"
  mode       = 420 ### 0644
  uid        = 0
  gid        = 0
  content {
    mime    = "text/plain"
    content = join("\n", var.ca_ssh_public_keys)
  }
}

data ignition_file "ca_tls_public_keys" {
  count = local.ca_tls_public_keys ? 1 : 0

  filesystem = "root"
  path       = "/etc/ssl/certs/root-ca.pem"
  mode       = 420 ### 0644
  uid        = 0
  gid        = 0
  content {
    mime    = "text/plain"
    content = join("\n", var.ca_tls_public_keys)
  }
}

data ignition_file "bastion_ssh_auth_keys" {
  count = local.bastion_ssh_auth_keys ? 1 : 0

  filesystem = "root"
  path       = "/etc/ssh/bastion_authorized_keys"
  mode       = 420 ### 0644
  uid        = 0
  gid        = 0
  content {
    mime    = "text/plain"
    content = join("\n", var.bastion_ssh_auth_keys)
  }
}

data ignition_systemd_unit "service" {
  name    = "bastion.service"
  content = <<-EOT
    [Unit]
    Description="Bastion Tower"
    [Service]
    ExecStartPre=-/usr/bin/rkt rm --uuid-file="/var/cache/bastion-service.uuid"
    ExecStart=/usr/bin/rkt run \
      --insecure-options=image \
      --volume bastion,kind=empty,readOnly=false \
      --mount volume=bastion,target=/usr/etc/ssh \
      ${local.bastion_ssh_auth_keys ? "--volume authorized-keys,kind=host,source=/etc/ssh/bastion_authorized_keys,readOnly=true" : ""} \
      ${local.bastion_ssh_auth_keys ? "--mount volume=authorized-keys,target=/var/lib/bastion/authorized_keys" : ""} \
      ${local.ca_ssh_public_keys ? "--volume ssh-ca,kind=host,source=/etc/ssh/ssh_ca_rsa_keys.pub,readOnly=true" : ""} \
      ${local.ca_ssh_public_keys ? "--mount volume=ssh-ca,target=/etc/ssh/ssh_ca_rsa_key.pub" : ""} \
      ${format("%s:%s", var.docker_repo, var.docker_tag)} \
      --name=bastion \
      ${local.ca_ssh_public_keys ? "--set-env=TRUSTED_USER_CA_KEYS=/etc/ssh/ssh_ca_rsa_key.pub" : ""} \
      --set-env=LISTEN_PORT=${var.bastion_ssh_port} \
      --set-env=PUBKEY_AUTHENTICATION=${local.bastion_ssh_auth_keys ? "true" : "false"} \
      # --user=4096 \
      # --group=4096 \
      --net=host \
      --dns=host
    ExecStop=-/usr/bin/rkt stop --uuid-file="/var/cache/bastion-service.uuid"
    Restart=always
    RestartSec=5
    [Install]
    WantedBy=multi-user.target
  EOT
}

data ignition_config "bastion" {
  users = [
    data.ignition_user.core.rendered,
    local.ca_ssh_public_keys ? data.ignition_user.admin[0].rendered : "",
  ]
  files = [
    local.ca_ssh_public_keys ? data.ignition_file.sshd_config[0].rendered : "",
    local.ca_ssh_public_keys ? data.ignition_file.auth_principals_core[0].rendered : "",
    local.ca_ssh_public_keys ? data.ignition_file.auth_principals_admin[0].rendered : "",
    local.ca_ssh_public_keys ? data.ignition_file.ca_ssh_public_keys[0].rendered : "",
    local.ca_tls_public_keys ? data.ignition_file.ca_tls_public_keys[0].rendered : "",
    local.bastion_ssh_auth_keys ? data.ignition_file.bastion_ssh_auth_keys[0].rendered : "",
  ]
  systemd = [
    data.ignition_systemd_unit.service.rendered,
  ]
}
