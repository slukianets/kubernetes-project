provider "aws" {}



resource "aws_instance" "kube-cluster-master" {
  count = 1
  ami           = "ami-0d359437d1756caa8"
  instance_type = "t2.medium"
  key_name      = "kube-test"
  vpc_security_group_ids = ["sg-07acc333255801ab1", "sg-0dfaee782e1a5faca", "sg-0b1d9adc4b61267e7"]
  user_data = templatefile("user_data.sh.tpl", {name = "k8s-master"})
  tags = {
      Name = "Kubernetes-Master${count.index + 1}"
    }
  root_block_device {
      volume_size = 15
    }
}

resource "aws_instance" "kube-cluster-node" {
  count = 2
  ami           = "ami-0d359437d1756caa8"
  instance_type = "t2.medium"
  key_name      = "kube-test"
  vpc_security_group_ids = ["sg-089178f7440263120", "sg-07acc333255801ab1", "sg-0dfaee782e1a5faca", "sg-0b1d9adc4b61267e7"]
  user_data = templatefile("user_data.sh.tpl", {name = "k8s-node0${count.index + 1}"})
  tags = {
      Name = "Kubernetes-Node0${count.index + 1}"
    }
  root_block_device {
      volume_size = 15
    }
}

output "master_ip" {
  value = ["${aws_instance.kube-cluster-master.*.public_ip}"]
}

output "node_ip" {
  value = ["${aws_instance.kube-cluster-node.*.public_ip}"]
}
