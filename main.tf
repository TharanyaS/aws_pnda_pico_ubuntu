data "aws_ami" "ubuntu1404" {
  most_recent = true
  owners = [
    "099720109477"]
  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }
  filter {
    name = "virtualization-type"
    values = [
      "hvm"]
  }
}

resource "aws_instance" "bastion" {
  ami           = "${data.aws_ami.ubuntu1404.id}"
  instance_type = "${var.BastionFlavor}"
  key_name = "${var.ssh_key_name}"
  disable_api_termination = "false"
  instance_initiated_shutdown_behavior = "stop"
  monitoring = "false"
  security_groups = ["${aws_security_group.sshSg.name}"]
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 30
  }
  associate_public_ip_address = "true"
  tags {
    Name = "${var.cluster_name}-bastion"
    node_type = "bastion"
    pnda_cluster = "${var.cluster_name}"
	node_idx  = ""
  }
}

resource "aws_instance" "edge" {
  ami           = "${data.aws_ami.ubuntu1404.id}"
  instance_type = "${var.EdgeFlavor}"
  key_name = "${var.ssh_key_name}"
  instance_initiated_shutdown_behavior = "stop"
  associate_public_ip_address = false
  security_groups = ["${aws_security_group.pndaSg.name}", "${aws_security_group.sshSg.name}"]
  root_block_device {
  volume_size = 30
  delete_on_termination = "true"
  }
  ebs_block_device = [{
    device_name = "/dev/sdc"
    volume_size = "${var.logvolumesize}"
  }]
  tags {
    Name = "${var.cluster_name}-hadoop-edge"
    node_type = "hadoop-edge"
    pnda_cluster = "${var.cluster_name}"
	node_idx = ""
  }
}

resource "aws_instance" "mgr-1" {
  ami           = "${data.aws_ami.ubuntu1404.id}"
  instance_type = "${var.Manager1Flavor}"
  key_name = "${var.ssh_key_name}"
  monitoring = "false"
  instance_initiated_shutdown_behavior = "stop" 
  associate_public_ip_address = false
  security_groups = ["${aws_security_group.pndaSg.name}", "${aws_security_group.sshSg.name}"]
  ebs_block_device = [{
    device_name = "/dev/sda1"
    volume_size = 30
  },
  {
    device_name = "/dev/sdc"
    volume_size = "${var.logvolumesize}"
  }]
  tags {
    Name = "${var.cluster_name}-hadoop-mgr-1"
    node_type = "hadoop-mgr"
    pnda_cluster = "${var.cluster_name}"
	node_idx = ""
  }
}

resource "aws_instance" "kafka" {
  ami           = "${data.aws_ami.ubuntu1404.id}"
  instance_type = "${var.KafkaFlavor}"
  key_name = "${var.ssh_key_name}"
  availability_zone = "${var.awsAvailabilityZone}"
  instance_initiated_shutdown_behavior = "stop"
  security_groups = ["${aws_security_group.pndaSg.name}", "${aws_security_group.sshSg.name}", "${aws_security_group.kafkaSg.name}"]
  count = "${var.number_of_kafkanodes}"
  monitoring = "false"
  associate_public_ip_address = "false"
  root_block_device {
    volume_size = 30
    delete_on_termination = "true"
  }
  ebs_block_device = [{
    device_name = "/dev/sdc"
    volume_size = "${var.logvolumesize}"
  }]
  tags {
    Name = "${var.cluster_name}-kafka-${count.index}"
    node_type = "kafka"
    pnda_cluster = "${var.cluster_name}"
	node_idx = "${count.index}"
  }
}

resource "aws_instance" "dn" {
  ami           = "${data.aws_ami.ubuntu1404.id}"
  instance_type = "${var.DatanodeFlavor}"
  key_name = "${var.ssh_key_name}"
  instance_initiated_shutdown_behavior = "stop"
  count      = "${var.number_of_datanodes}" 
  security_groups = ["${aws_security_group.pndaSg.name}", "${aws_security_group.sshSg.name}"]
  monitoring = "false"
  associate_public_ip_address = "false"
  root_block_device {
  volume_size = 30
  delete_on_termination = "true"
  }
  ebs_block_device = [{
    device_name = "/dev/sdc"
    volume_size = "${var.logvolumesize}"
  },
  {
    device_name = "/dev/sdd"
    volume_size = 35
  }]
  tags {
    Name = "${var.cluster_name}-hadoop-dn-${count.index}"
    node_type = "hadoop-dn"
    pnda_cluster = "${var.cluster_name}"
	node_idx = "${count.index}"
  }
}

resource "aws_security_group" "kafkaSg" {
  description = "Access to Kafka"

  ingress {
    from_port   = 9090
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["${var.whitelistKafkaAccess}"]  
  }
}

resource "aws_security_group" "sshSg" {
  description = "Access to pnda instances"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.whitelistSshAccess}"]  
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    #security_groups  = "${aws_security_group.pndaSg.name}"  
    self = "true"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  
  }
}
resource "aws_security_group" "pndaSg" {
  description = "Access to pnda UIs"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.whitelistSshAccess}"]  
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self = "true"  
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups  = ["${aws_security_group.sshSg.id}" ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks  = ["0.0.0.0/0"]
  }
}

resource "local_file" "cluster_ip" {
  depends_on = ["aws_instance.bastion", "aws_instance.edge", "aws_instance.mgr-1", "aws_instance.kafka", "aws_instance.dn"]
  content     = "bastion_private_ip: ${ aws_instance.bastion.private_ip } \npublic_ip: ${ aws_instance.bastion.public_ip } \nhadoop-edge_private_ip: ${ aws_instance.edge.private_ip } \nhadoop-mgr-1_private_ip: ${ aws_instance.mgr-1.private_ip }\nhadoop-dn_private_ip: [${join(",",aws_instance.dn.*.private_ip)}] \nkafka_private_ip: [${join(",", aws_instance.kafka.*.private_ip)}]"
  filename = "${path.cwd}/output.yaml"
}
resource "null_resource" "deploy_PNDA" {
  depends_on = [
    "local_file.cluster_ip", "null_resource.install_requirement"
  ]

  provisioner "local-exec" {
    command = "python create_pico.py create -b ${var.branch} -u ${var.ssh_user} -s ${var.ssh_key_name} -f pico -i ${var.mirror_server_ip}  -a ${var.access_key} -r ${var.region} -k ${var.secret_key}"
  }
}
resource "null_resource" "install_requirement" {
  depends_on = ["local_file.cluster_ip"]
  provisioner "local-exec" {
    command = "pip install -r requirements.txt"
  }
}
