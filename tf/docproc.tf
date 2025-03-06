locals {
  docproc_count = 1
}

resource "aws_instance" "docproc" {
  count = local.docproc_count

  instance_type = "c8g.xlarge"
  ami           = local.arm_ami
  key_name      = local.ssh_key
  subnet_id     = data.aws_subnet.this.id
  user_data     = filebase64("${path.module}/scripts/init.sh")
  vpc_security_group_ids = [
    data.aws_security_group.default.id,
    data.aws_security_group.ssh.id,
  ]

  root_block_device {
    delete_on_termination = true
    volume_type           = "gp3"
    volume_size           = 100
  }

  tags = {
    "Name"        = "vespa-docproc"
    "DisplayName" = "vespa-docproc"
    "Group"       = "vespa"
    "Role"        = "docproc"
  }
}

resource "aws_ebs_volume" "docproc" {
  count = local.docproc_count

  lifecycle {
    replace_triggered_by = [aws_instance.docproc[count.index].private_ip]
  }

  availability_zone = data.aws_subnet.this.availability_zone
  size              = 150
  type              = "gp3"
}

resource "aws_volume_attachment" "docproc" {
  count       = local.docproc_count
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.docproc[count.index].id
  instance_id = aws_instance.docproc[count.index].id
}

resource "null_resource" "deploy-docproc" {
  count = local.docproc_count

  lifecycle {
    replace_triggered_by = [aws_instance.docproc[count.index].private_ip]
  }

  connection {
    type = "ssh"
    user = "ec2-user"
    host = aws_instance.docproc[count.index].private_ip
  }

  provisioner "remote-exec" {
    inline = ["cloud-init status --wait"]
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${local.deploy_dir}",
      "mkdir -p /opt/anduin/benchmark",
      "mkdir -p ${local.data_dir}/{logs,var}",
      "touch ${local.deploy_docker}",
      "cp ${local.deploy_docker} ${local.deploy_docker}.bak"
    ]
  }

  provisioner "file" {
    content = templatefile("${path.module}/deploy/docker-compose.yaml", {
      command        = "services"
      config_servers = join(",", aws_instance.configserver[*].private_dns)
    })
    destination = local.deploy_docker
  }

  provisioner "remote-exec" {
    inline = [
      "docker-compose -f ${local.deploy_docker} up -d"
    ]
  }

  depends_on = [aws_instance.docproc, null_resource.deploy-configserver]
}

output "docproc_ips" {
  value = aws_instance.docproc[*].private_ip
}

output "docproc_dnses" {
  value = aws_instance.docproc[*].private_dns
}
