locals {
  search_count = 2
}

resource "aws_instance" "search" {
  count = local.search_count

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
    "Name"        = "vespa-search"
    "DisplayName" = "vespa-search"
    "Group"       = "vespa"
  }
}

resource "null_resource" "deploy-search" {
  count = local.search_count

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

  depends_on = [aws_instance.search]
}

output "search_ips" {
  value = aws_instance.search[*].private_ip
}

output "search_dnses" {
  value = aws_instance.search[*].private_dns
}
