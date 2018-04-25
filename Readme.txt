# PNDA pico - ubuntu
Non-deepinsight users:
1. Install git
	Ubuntu: apt-get install -y git
	RHEL: yum install -y git
2. Install wget 
	Ubuntu: apt-get install -y wget 
	RHEl: yum install -y wget
3. git clone https://github.com/TharanyaS/aws_pnda_pico_ubuntu.git
4. cd aws_pnda_pico_ubuntu/
5. Run install_packages.sh to install necessary packages 
6. Copy the private_key_file to aws_pnda_pico_ubuntu directory
7. Provide the value of ssh_key_name and mirror_server_ip in terraform.tfvars file
8. Run "terraform apply" command
9. Provide the values for access_key, secret_key and region
Example:
var.access_key
  Enter a value: xxxx

var.secret_key
  Enter a value: xxxxxx

var.region
  Enter a value: us-east-1


DeepInsight Users:
1. Install git 
	Ubuntu: apt-get install -y git
	RHEL: yum install -y git
2. Install wget
        Ubuntu: apt-get install -y wget
        RHEl: yum install -y wget
3. git clone https://github.com/TharanyaS/aws_pnda_pico_ubuntu.git
4. cd aws_pnda_pico_ubuntu/
5. Run install_packages.sh to install necessary packages 
6. Copy the private_key_file to aws_pnda_pico_ubuntu directory
7. Provide the value of ssh_key_name and mirror_server_ip in terraform.tfvars file
8. Run "terraform apply" command.
9. Provide the values for access_key, secret_key, and region
Example:
var.access_key
  Enter a value: xxxx

var.secret_key
  Enter a value: xxxxxx

var.region
  Enter a value: us-east-1

DeepInsight Users from UI:
1. Copy private key file to aws_pnda_pico_ubuntu directory
2. Provide the key_name and mirror_server_ip for ssh_key_name and mirror_server_ip variable respectively in terraform.tfvars file.
3. Save it and add application from UI.
