output "public_ip" {
  value = "${aws_instance.eurotunnel.public_ip}"
}
