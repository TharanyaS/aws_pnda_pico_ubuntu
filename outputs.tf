output "bastion_private_ip" {
  value = "${ aws_instance.bastion.private_ip }"
}

output "public_ip" {
  value = "${ aws_instance.bastion.public_ip }"
}

output "hadoop-edge_private_ip" {
  value =  "${ aws_instance.edge.private_ip }"
}

output "hadoop-mgr-1_private_ip" {
  value = "${ aws_instance.mgr-1.private_ip }"
}

output "hadoop-dn_private_ip" {
  value = "${ aws_instance.dn.*.private_ip }"
}

output "kafka_private_ip" {
  value = "${ aws_instance.kafka.*.private_ip }"
} 
