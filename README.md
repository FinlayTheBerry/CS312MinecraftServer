# What is this?
My final project for CS312 System Administration at Oregon State University was to create a fully automated collection of scripts to provision and configure a Minecraft server on an AWS EC2 instance. This repository is my final submission to that assignment. Despite being for a class these scripts are useful to anyone who wants to setup a Minecraft server on AWS automatically.  

# What do these scripts do?
`provision.sh` uses Terraform to spin up a t3.micro EC2 instance, allows Minecraft through the firewall, and assigns a static IP address.  
`configure.sh` uses Ansible to setup a SystemD service to run a Minecraft server as a low-privilege user on start up.  

# Required dependencies:
`provision.sh` requires the AWS CLI (aws) and Terraform (terraform).  
`configure.sh` requires only Ansible (ansible-playbook).  

# Required setup:
You need to place your AWS CLI credentials into `~/.aws/credentials`.  
Other than that these scripts are fully automated and require no user interaction.  

# How to use?
First run `./provision.sh` to create the EC2 instance.  
Then run `./configure.sh` to setup the Minecraft server.  
NOTE: You need to log in to the aws cli before running `./provision.sh`.  

# How to connect?
`./provision.sh` will print the Minecraft server IP address after running. Copy this IP address into Minecraft to connect (NOTE: The server IP address can also be found in the `ansible_host` field in `./minecraft_hosts.ini`).  

# What happens under the hood?  
Under the hood `./provision.sh` uses Terraform and the AWS CLI to do the following:
- Create a new security group allowing all outbound traffic and inbound traffic for Minecraft or SSH.  
- Create a new RSA 4096 keypair and saves the private key to `./minecraft_key.pem`.  
- Allocate a new static IP using AWS elastic IPs.  
- Create a new t3.micro EC2 instance with the created security group, keypair, and elastic IP.  

Under the hood `./configure.sh` uses Ansible to do the following:
- Update all system packages.  
- Install java 26.  
- Create a low privilege user called Minecraft.  
- Use `./get_latest_jar_url.py` to locate the download url for the latest Minecraft server jar.  
- Download the Minecraft server jar file.  
- Accept the Minecraft EULA.  
- Create a SystemD service called `minecraft.service`.  
- Start this service and enable it to run on boot.  
