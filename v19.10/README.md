> :warning: **WARNING**:
> It is a very first version of the project that uses Terraform "remote-exec" provisioner to bootstrap software to the deployed instance.
> Despite of the fact that it works perfect, using Terraform for instance provisioning is recommended only as a last resort option.
> Using third-parties provisioner (configuration management systems) gives us more flexibility in configuration and that is what exactly Terraform recommends to do.
> Please use the latest version of the project (that is using Terraform + Ansible integration) located within the main project directory.

# Eurotunnel
This simple Terraform script allows you to automatically deploy AWS EC2 instance and provision ready-to-use IPsec VPN along with Telegram MTProto proxy.  
IPsec VPN is based on strongSwan.  
Official Docker image is used to run Telegram Messenger MTProto proxy.  
Default IPsec configuration within this script is suitable for two cases:
- site-to-site VPN
- remote access VPN  
![Alt text](../images/scheme.png?raw=true "Deployed scheme")
## Usage
### Prerequisites
Make sure Terraform version 0.12 or higher is installed.  
Perform `terraform init` command within repository directory.  
### Deployment preconditions
All variable values within `vars.tf` file starting with `YOUR` prefix should be specified.  
`terraform.tvfars` file contains your `AWS_ACCESS_KEY` and `AWS_SECRET_KEY` keys.  
### Deployment
Simply run `./pipeline.sh` file and type `yes` when terraform asks about deploy.  
It will generate a new SSH key pair, deploy all AWS resources required and finally spin up AWS instance followed by software provisioning.  
```
Starting pipeline...
==============================================================
Generating a key-pair
-----------------------------------
Generating public/private rsa key pair.
centoskey already exists.
Overwrite (y/n)? Your identification has been saved in centoskey.
Your public key has been saved in centoskey.pub.
The key fingerprint is:
SHA256:xabDOaqA14tTigfHpYtRbg6240gM/ZVwGb6uA1/gWLY
The key's randomart image is:
+---[RSA 2048]----+
|      .          |
|     . o .       |
|    . +   +      |
| .. =o + =       |
|.+.B o+ S        |
|*oOoEo.. o       |
|o%+*o.o          |
|=+*oo+           |
|ooo.+.           |
+----[SHA256]-----+
==============================================================
Applying terraform configuration
-----------------------------------
```
Deployment output will contain public IP address that is bind to the specified domain.
```
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

public_ip = 13.48.149.34
==============================================================
Done!
==============================================================
```
You can use specified domain name or simply public IP of deployed instance as VPN server destination and Telegram proxy address.  
