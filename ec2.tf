resource aws_instance "bastion" {
  instance_type     = var.instance_type
  monitoring        = var.monitoring
  availability_zone = element(data.aws_availability_zones.current.names, var.availability_zone)
  user_data         = data.ignition_config.bastion.rendered
  subnet_id         = var.vpc_subnet_id

  ami = (
    var.ami_image != "" ? var.ami_image : (
      var.ami_vendor == "flatcar"
      ? data.aws_ami.flatcar[0].image_id
      : data.aws_ami.coreos[0].image_id
    )
  )

  vpc_security_group_ids = concat(
    [aws_security_group.bastion.id],
    var.security_groups,
  )

  tags = merge(local.tags, {
    Name = format(local.name_tmpl, "bastion")
  })

  volume_tags = merge(local.tags, {
    Name = format(local.name_tmpl, "bastion")
  })

  credit_specification {
    cpu_credits = var.cpu_credits
  }

  lifecycle {
    ignore_changes = [
      ami,
    ]
  }

  root_block_device {
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    delete_on_termination = true
  }
}
