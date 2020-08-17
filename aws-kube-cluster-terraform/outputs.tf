output "master_ip" {
  value = ["${aws_instance.kube-cluster-master.*.public_ip}"]
}

output "node_ip" {
  value = ["${aws_instance.kube-cluster-node.*.public_ip}"]
}
