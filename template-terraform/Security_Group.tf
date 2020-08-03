provider "aws" {}

variable "ec2_ingress_port_kube" {
  description = "Allowed port for kubernetes"
  type = map
  default = {
    "0" = ["30000", "32767", "NodePort Services"]
    "1" = ["6443", "6443", "Kubernetes API server"]
    "2" = ["2379", "2380", "Etcd server client API"]
    "3" = ["10251", "10251", "Kube scheduler"]
    "4" = ["10250", "10250", "Kubelet API"]
    "5" = ["10252", "10252", "Kube controller manager"]
  }
}

variable "ec2_ingress_port_weave_net" {
  description = "Allowed port for Weave Net"
  type = map
  default = {
    "tcp" = ["6783", "6783", "Weave Net"]
    "udp" = ["6783", "6784", "Weave Net"]
  }
}

data "aws_vpc" "default" {
  default = true
}


resource "aws_security_group" "kubernetes_sg" {
  name = "Kubernetes security group"

  dynamic "ingress" {
    for_each = var.ec2_ingress_port_kube
    content {
      from_port = ingress.value[0]
      to_port = ingress.value[1]
      protocol = "tcp"
      description = ingress.value[2]
      cidr_blocks = ["${data.aws_vpc.default.cidr_block}"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Kubernetes security group"
  }
}


resource "aws_security_group" "weave_net_sg" {
  name = "Weave Net security group"

  dynamic "ingress" {
    for_each = var.ec2_ingress_port_weave_net
    content {
      protocol = ingress.key
      from_port = ingress.value[0]
      to_port = ingress.value[1]
      description = ingress.value[2]
      cidr_blocks = ["${data.aws_vpc.default.cidr_block}"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Weave Net security group"
  }
}
