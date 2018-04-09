apt-get install git
apt-get install -y zip unzip
wget https://releases.hashicorp.com/terraform/0.10.8/terraform_0.10.8_linux_amd64.zip
unzip terraform_0.10.8_linux_amd64.zip
mv terraform /usr/local/bin/
apt-get install python-setuptools
apt-get install python-pip
pip install jinja2
pip install gitpython
terraform init
