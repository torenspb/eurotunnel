variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "instance" {}
variable "connections" {}
variable "route53" {}
variable "provisioner" {}
variable "FILE" {
  default = "variables.json"
}
variable "PROVISION" {
  default = 1
}

provider "aws" {
  region     = "${var.instance["region"]}"
  access_key = "${var.AWS_ACCESS_KEY}"
  secret_key = "${var.AWS_SECRET_KEY}"
}

resource "aws_security_group" "base_sg" {
  name        = "base_sg"
  description = "Security group allows ingress connections for SSH, HTTPS, IKE, ESP protocols on the given ports"

  ingress {
    from_port   = "${var.connections["ssh_port"]}"
    to_port     = "${var.connections["ssh_port"]}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "${var.connections["tgproxy_port"]}"
    to_port     = "${var.connections["tgproxy_port"]}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = var.connections["ike_ports"]

    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "udp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "bootkey" {
  key_name   = "${var.connections["ssh_key_name"]}"
  public_key = "${file("${var.connections["ssh_pub_key"]}")}"
}

resource "aws_instance" "eurotunnel" {
  ami           = "${var.instance["ami"]}"
  instance_type = "${var.instance["type"]}"
  key_name      = "${aws_key_pair.bootkey.key_name}"
  user_data     = <<-EOF
                  #!/bin/bash -ex
                  sudo semanage port -a -t ssh_port_t -p tcp ${var.connections["ssh_port"]}
                  sudo sed -i -e 's/#Port 22/Port ${var.connections["ssh_port"]}/g' /etc/ssh/sshd_config
                  sudo systemctl restart sshd
                  EOF

  root_block_device {
    delete_on_termination = true
  }

  security_groups = [
    "${aws_security_group.base_sg.name}",
  ]

  connection {
    host        = self.public_ip
    user        = "${var.connections["username"]}"
    private_key = "${file("${aws_key_pair.bootkey.key_name}")}"
    port        = "${var.connections["ssh_port"]}"
  }

  provisioner "remote-exec" {
    inline = ["logger 'Instance is ready for the provisioning!'"]
  }

  provisioner "local-exec" {
    command = <<EOT
if [ ${var.PROVISION} -eq 1 ]; then
    ansible-playbook -u ${var.connections["username"]} -i '${self.public_ip}:${var.connections["ssh_port"]},' \
     --private-key ${aws_key_pair.bootkey.key_name} --ssh-common-args='-o StrictHostKeyChecking=no' --extra-vars '@${var.FILE}' ansible/provision.yml
else
    logger "provision is not required"
fi
EOT
  }
}

resource "aws_route53_record" "address-record" {
  count = var.route53["enabled"] ? 1 : 0

  zone_id = "${var.route53["zone_id"]}"
  name    = "${var.route53["domain"]}"
  type    = "A"
  ttl     = "300"
  records = [
    "${aws_instance.eurotunnel.public_ip}",
  ]
}

output "public_ip" {
  value = "${aws_instance.eurotunnel.public_ip}"
}
