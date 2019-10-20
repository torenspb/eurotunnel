provider "aws" {
  access_key = "${var.AWS_ACCESS_KEY}"
  secret_key = "${var.AWS_SECRET_KEY}"
  region     = "${var.EC2["region"]}"
}

resource "aws_security_group" "allow_ssh_https_ike_esp" {
  name        = "allow_ssh_https_ike_esp"
  description = "Allows ingress SSH, HTTPS, IKE, ESP connections to the default ports"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "bootkey" {
  key_name   = "${var.SSH_KEY["name"]}"
  public_key = "${file("${var.SSH_KEY["pubpath"]}")}"
}

resource "aws_instance" "eurotunnel" {
  ami           = "${var.EC2["ami"]}"
  instance_type = "${var.EC2["type"]}"
  key_name      = "${aws_key_pair.bootkey.key_name}"

  root_block_device {
    delete_on_termination = true
  }

  security_groups = [
    "${aws_security_group.allow_ssh_https_ike_esp.name}",
  ]

  connection {
    host        = self.public_ip
    user        = "${var.INSTANCE_USERNAME}"
    private_key = "${file("${aws_key_pair.bootkey.key_name}")}"
  }

  provisioner "file" {
    source      = "swanctl.conf"
    destination = "swanctl.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo setenforce 0",
      "sudo sed -i 's/=enforcing/=disabled/g' /etc/selinux/config",
      "sudo echo 'net.ipv4.ip_forward=1' | sudo tee /etc/sysctl.conf",
      "sudo sysctl -p",
      "sudo yum -y update",
      "sudo yum -y install epel-release",
      "sudo yum -y install docker strongswan",
      "sudo ip tunnel add ${var.GRE["interface"]} local any remote ${var.ROUTER["external_addr"]}",
      "sudo ip tunnel change ${var.GRE["interface"]} ttl 64",
      "sudo ip link set ${var.GRE["interface"]} up",
      "sudo ip address add ${var.GRE["local_address"]} dev ${var.GRE["interface"]}",
      "sudo ip l set ${var.GRE["interface"]} mtu ${var.GRE["mtu"]}",
      "sudo ip r add ${var.ROUTER["local_subnet"]} via ${var.GRE["remote_address"]} dev ${var.GRE["interface"]}",
      "sudo echo '*/1 * * * * ping ${var.GRE["remote_address"]} -c 1 > /dev/null' > ping_cron",
      "sudo crontab ping_cron",
      "sudo iptables --table nat --append POSTROUTING -j MASQUERADE",
      "sudo iptables -t mangle -A FORWARD -m policy --pol ipsec --dir in -p tcp -m tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1361:1536 -j TCPMSS --set-mss 1360",
      "sudo iptables -t mangle -A FORWARD -m policy --pol ipsec --dir out -p tcp -m tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1361:1536 -j TCPMSS --set-mss 1360",
      "sudo sed -i -e 's/PSK/${var.PSK}/g' swanctl.conf",
      "sudo cp swanctl.conf /etc/strongswan/swanctl/swanctl.conf",
      "sudo rm -f swanctl.conf",
      "sudo systemctl enable strongswan-swanctl",
      "sudo systemctl enable docker",
      "sudo systemctl start strongswan-swanctl",
      "sudo systemctl start docker",
      "sudo docker run -d -p443:443 --name=mtproto-proxy --restart=always -v proxy-config:/data -e SECRET=${var.SECRET} telegrammessenger/proxy:latest",
    ]
  }
}

resource "aws_route53_record" "address-record" {
  zone_id = "${var.HOSTED_ZONE_ID}"
  name    = "${var.DOMAIN_NAME}"
  type    = "A"
  ttl     = "300"

  records = [
    "${aws_instance.eurotunnel.public_ip}",
  ]
}
