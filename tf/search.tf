locals {
  search_count = 2
}

resource "aws_instance" "search" {
  count = local.search_count

  instance_type = "m8g.xlarge"
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
    "Name"        = "vespa-search"
    "DisplayName" = "vespa-search"
    "Group"       = "vespa"
    "Role"        = "search"
  }
}

resource "aws_ebs_volume" "search" {
  count = local.search_count

  lifecycle {
    replace_triggered_by = [aws_instance.search[count.index].private_ip]
  }

  availability_zone = data.aws_subnet.this.availability_zone
  size              = 150
  type              = "gp3"

  tags = {
    Name = "vespa-search"
  }
}

resource "aws_volume_attachment" "search" {
  count       = local.search_count
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.search[count.index].id
  instance_id = aws_instance.search[count.index].id
}

resource "null_resource" "deploy-search" {
  count = local.search_count

  lifecycle {
    replace_triggered_by = [aws_instance.search[count.index].private_ip]
  }

  connection {
    type = "ssh"
    user = "ec2-user"
    host = aws_instance.search[count.index].private_ip
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

  depends_on = [aws_instance.search, null_resource.deploy-configserver]
}

output "search_ips" {
  value = aws_instance.search[*].private_ip
}

output "search_dnses" {
  value = aws_instance.search[*].private_dns
}
