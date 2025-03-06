locals {
  configserver_count = 1
}

resource "aws_instance" "configserver" {
  count = local.configserver_count

  instance_type = "m8g.large"
  ami           = local.arm_ami
  key_name      = local.ssh_key
  subnet_id     = data.aws_subnet.this.id
  user_data     = filebase64("${path.module}/scripts/init.sh")
  vpc_security_group_ids = [
    data.aws_security_group.default.id,
    data.aws_security_group.ssh.id,
  ]
  tags = {
    "Name"        = "vespa-configserver"
    "DisplayName" = "vespa-configserver"
  }
}

resource "null_resource" "deploy-configserver" {
  for_each = {
    for idx, instance in aws_instance.configserver[*] : "${idx}" => instance
  }

  connection {
    type = "ssh"
    user = "ec2-user"
    host = each.value.private_ip
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
      command        = "configserver,services"
      config_servers = join(",", aws_instance.configserver[*].private_dns)
    })
    destination = local.deploy_docker
  }

  depends_on = [aws_instance.configserver]
}

output "configserver_ips" {
  value = aws_instance.configserver[*].private_ip
}

output "configserver_dnses" {
  value = aws_instance.configserver[*].private_dns
}
