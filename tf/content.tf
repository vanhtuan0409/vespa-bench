locals {
  content_count = 3
}

resource "aws_instance" "content" {
  count = local.content_count

  instance_type = "i8g.xlarge"
  ami           = local.arm_ami
  key_name      = local.ssh_key
  subnet_id     = data.aws_subnet.this.id
  user_data     = filebase64("${path.module}/scripts/init.sh")
  vpc_security_group_ids = [
    data.aws_security_group.default.id,
    data.aws_security_group.ssh.id,
  ]
  tags = {
    "Name"        = "vespa-content"
    "DisplayName" = "vespa-content"
  }
}

resource "null_resource" "deploy-content" {
  for_each = {
    for idx, instance in aws_instance.content[*] : "${idx}" => instance
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
      command        = "services"
      config_servers = join(",", aws_instance.configserver[*].private_dns)
    })
    destination = local.deploy_docker
  }

  depends_on = [aws_instance.content]
}

output "content_ips" {
  value = aws_instance.content[*].private_ip
}

output "content_dnses" {
  value = aws_instance.content[*].private_dns
}
