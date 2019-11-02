# AWS credentials should be specified in a separate terraform.tvfars file with the following content:
# AWS_ACCESS_KEY = "YOUR_ACCESS_KEY"
# AWS_SECRET_KEY = "YOUR_SECRET_KEY"
#
variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}

# Setting region, instance type and Centos AMI identifier
variable "EC2" {
  type = "map"

  default = {
    region = "eu-north-1"
    type   = "t3.micro"
    ami    = "ami-5ee66f20"
  }
}

# Default username of selected AMI
variable "INSTANCE_USERNAME" {
  default = "centos"
}

# Default SSH port can be overridden in here
# For the security reasons it's better to use port different than default one
variable "SSH_PORT" {
  default = "22"
}

# SSH key used to connect to an instance
variable "SSH_KEY" {
  type = "map"

  default = {
    name    = "centoskey"
    pubpath = "centoskey.pub"
  }
}

# Domain name that is hosted within Route53
# A - record for that domain name will be created during deployment
variable "DOMAIN_NAME" {
  default = "YOURdomain.example"
}

# Hosted zone ID that is associated with domain name
variable "HOSTED_ZONE_ID" {
  default = "YOUR_HOSTED_ZONE_ID"
}

# Router addresses that are used for site-to-site VPN connection
variable "ROUTER" {
  type = "map"

  default = {
    external_addr = "YOUR_ROUTER_EXTERNAL_IP"
    local_subnet  = "192.168.88.0/24"
  }

}

# GRE tunnel configuration
variable "GRE" {
  type = "map"

  default = {
    interface      = "gre-tunnel0"
    local_address  = "10.10.10.1/30"
    remote_address = "10.10.10.2"
    mtu            = "1418"
  }
}

# PSK that is used within IPsec connection
variable "PSK" {
  default = "YOUR_presharedkey"
}

# Secret that is used within Telegram app
variable "SECRET" {
  default = "YOUR_secretkey"
}
