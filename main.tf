locals {
  network_interface = { for indx, v in var.network_interface : indx => v }
  external_disks    = { for indx, v in var.external_disks : indx => v }
}

##################################
# Common Instance
##################################
resource "aws_instance" "this" {
  ami               = var.ami
  instance_type     = var.instance_type
  availability_zone = var.availability_zone

  associate_public_ip_address = var.associate_public_ip_address
  subnet_id                   = var.subnet_id
  private_ip                  = var.private_ip
  secondary_private_ips       = var.secondary_private_ips
  vpc_security_group_ids      = var.vpc_security_group_ids

  disable_api_stop        = var.disable_api_stop
  disable_api_termination = var.disable_api_termination

  ebs_optimized = var.ebs_optimized

  get_password_data    = var.get_password_data
  monitoring           = var.monitoring
  iam_instance_profile = var.iam_instance_profile

  key_name = var.create_new_key ? aws_key_pair.this[0].key_name : var.key_name

  tags = merge(
    {
      Name = var.ec2_name
    },
    var.tags
  )

  dynamic "root_block_device" {
    for_each = var.root_block_device
    content {
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", null)
      encrypted             = lookup(root_block_device.value, "encrypted", null)
      iops                  = lookup(root_block_device.value, "iops", null)
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
      throughput  = lookup(root_block_device.value, "throughput")
      volume_size = lookup(root_block_device.value, "volume_size")
      volume_type = lookup(root_block_device.value, "volume_type")
    }
  }
  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device
    content {
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", null)
      device_name           = lookup(ebs_block_device.value, "device_name", null)
      encrypted             = lookup(ebs_block_device.value, "encrypted", null)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      throughput  = lookup(ebs_block_device.value, "throughput", null)
      volume_size = lookup(ebs_block_device.value, "volume_size", null)
      volume_type = lookup(ebs_block_device.value, "volume_type", null)
    }
  }

  dynamic "metadata_options" {
    for_each = var.metadata_options
    content {
      http_endpoint               = lookup(metadata_options.value, "http_endpoint", "enabled")
      http_tokens                 = lookup(metadata_options.value, "http_tokens", "optional")
      http_put_response_hop_limit = lookup(metadata_options.value, "http_put_response_hop_limit", "1")
      instance_metadata_tags      = lookup(metadata_options.value, "instance_metadata_tags", "disabled")
    }
  }
  user_data                   = var.user_data
  user_data_base64            = var.user_data_base64
  user_data_replace_on_change = var.user_data_replace_on_change
}

##################################
# Key Pair
##################################
resource "tls_private_key" "this" {
  count     = var.create_new_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "this" {
  count      = var.create_new_key ? 1 : 0
  key_name   = "${var.ec2_name}-${var.availability_zone}"
  public_key = tls_private_key.this[0].public_key_openssh
}
resource "aws_secretsmanager_secret" "this" {
  count = var.create_new_key ? 1 : 0
  #TODO remove -1 at the end
  name  = "ssh-key-pair-${var.ec2_name}-${var.availability_zone}-1"
  recovery_window_in_days = 0
}
resource "aws_secretsmanager_secret_version" "this" {
  count         = var.create_new_key ? 1 : 0
  secret_id     = aws_secretsmanager_secret.this[0].id
  secret_string = tls_private_key.this[0].private_key_pem
}

##################################
# Network Interface
##################################
resource "aws_network_interface" "this" {
  for_each        = local.network_interface
  subnet_id       = lookup(each.value, "subnet_id", null)
  security_groups = try([lookup(each.value, "security_group")], null)
  private_ips     = try([lookup(each.value, "private_ip")], null)
  tags = merge(
    {
      Name = var.ec2_name
    },
    {
      Subnet = lookup(each.value, "subnet_id", null)
    },
    var.tags
  )
}
resource "aws_network_interface_attachment" "this" {
  for_each             = local.network_interface
  instance_id          = aws_instance.this.id
  network_interface_id = aws_network_interface.this[each.key].id
  device_index         = tonumber(each.key) + 1
}

##################################
# External EBS
##################################
resource "aws_ebs_volume" "this" {
  for_each          = local.external_disks
  availability_zone = var.availability_zone
  size              = lookup(each.value, "size", null)
  type              = lookup(each.value, "type", "gp2")
}
resource "aws_volume_attachment" "ebs_att" {
  for_each    = local.external_disks
  device_name = lookup(each.value, "device_name", null)
  volume_id   = aws_ebs_volume.this[each.key].id
  instance_id = aws_instance.this.id
}
