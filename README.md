# Eurotunnel
> Creating personal VPN service has never been so easy. (c) said no one so far  

Seriously though, using this Terraform project you'll be able to easily create your own ready-to-use IPsec VPN along with Telegram MTProto proxy.  
Combining Terraform and Ansible it automatically deploys and provisions AWS EC2 instance with all VPN-needed services:
* IPsec VPN based on strongSwan
* official Docker image used to run Telegram Messenger MTProto proxy  

Default IPsec configuration within this script is suitable for two cases:
- site-to-site VPN
- remote access VPN  
![Alt text](./images/scheme.png?raw=true "Deployed scheme")
## Usage
### Prerequisites
Make sure Terraform version 0.12 or higher is installed.  
Make sure Ansible version 2.5 or higher is installed.  
Perform `terraform init` command within repository directory.  
### Deployment preconditions
All variables are located within `variables.json` file and are being used both by Terraform and Ansible during deployment and provisioning processes.  
Variables are splitted into several sections and need to be changed by your values:
* instance - specify AWS region, AMI and instance type; current solution was developed and is only tested with `Centos 7` operating system
* connections - specify AMI username, SSH port you'd like to use (Terraform will change it during initial deployment), service ports and ssh-keys
* provisioner
  - tunnel - set `peer_wan` to your routers public WAN IP and `peer_lan` to your LAN network (if you want to use IPsec site-to-site VPN)
  - ipsec - `user` and `shared_key` are credentials for remote access VPN, `psk` is also needed for connection establishing
  - telegram - set `secret` that will be specified within your Telegram configuration
Leave the `route53` section with defaults if you don't have a domain parked on AWS or don't want to bind a domain to the created instance. Otherwise, set `enabled` option to `true` and specify your domain and AWS route53 zone id (should be created manually before).  
Also, environment variables containing AWS access and secret keys should be created:
```
export AWS_ACCESS_KEY="qwerty"
export AWS_SECRET_KEY="qwerty"
```
### Deployment
Simply run `./pipeline.sh` file and type `yes` when terraform asks about deploy.  
It will generate a new SSH key pair, deploy all AWS resources required and finally spin up AWS instance followed by software provisioning.  
```
Starting a pipeline...
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
Deployment output will contain public IP address (that is binded to the specified domain if configured).
```
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

public_ip = 13.13.0.1
==============================================================
Done!
==============================================================
```
You can use specified domain name or a public IP of the deployed instance as a VPN server destination and Telegram proxy server address.  

### Using with Jenkins
There is a Jenkinsfile under the `jenkins-pipeline` folder. It can be used for the infrastructure deployment and provisioning.
