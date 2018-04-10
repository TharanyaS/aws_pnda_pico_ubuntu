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
7. Run "terraform apply" command.
8. Provide the values for access_key, secret_key, mirror_ip of ubuntu mirror server and ssh_key_name - Ex: private_key
Example:
var.access_key
  Enter a value: xxxx

var.mirror_server_ip
  Enter a value: 54.12.123.32

var.secret_key
  Enter a value: xxxxxx

var.ssh_key_name
  Enter a value: private_key


Deepinsigh Users:
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
7. Run "terraform apply" command.
8. Provide the values for access_key, secret_key, mirror_ip of ubuntu mirror server and ssh_key_name - Ex: private_key
Example:
var.access_key
  Enter a value: xxxx

var.mirror_server_ip
  Enter a value: 54.12.123.32

var.secret_key
  Enter a value: xxxxxx

var.ssh_key_name
  Enter a value: private_key

