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

variable "ec2_ingress_port_http_https" {
  description = "Allowed port for HTTP and HTTPs"
  type = list
  default = ["80", "443"]
}

data "aws_vpc" "default" {
  default = true
}

data "external" "my_ip" {
  program = ["/bin/bash", "${path.root}/my_ip.sh"]
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

resource "aws_security_group" "http_https_sg" {
  name = "HTTP and HTTPs security group"

  dynamic "ingress" {
    for_each = var.ec2_ingress_port_http_https
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "HTTP and HTTPs security group"
  }
}

resource "aws_security_group" "ssh_for_my_ip_sg" {
  name = "ssh security group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.external.my_ip.result["my_ip"]}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ssh security group"
  }
}
output "kubernetes_sg" {
  value = aws_security_group.kubernetes_sg.id
}

output "weave_net_sg" {
  value = aws_security_group.weave_net_sg.id
}

output "http_https_sg" {
  value = aws_security_group.http_https_sg.id
}

output "ssh_for_my_ip_sg" {
  value = aws_security_group.ssh_for_my_ip_sg.id
}
