variable "environment" {
  default = "Kube-Cluster"
}

variable "vpc_network" {
  default = "172.16.0.0/16"
}

variable "public_subnets" {
  default = [
    "172.16.10.0/24",
    "172.16.11.0/24"
  ]
}

variable "private_subnets" {
  default = [
    "172.16.20.0/24",
    "172.16.21.0/24"
  ] 
}

variable "db_subnets" {
  default = [
    "172.16.30.0/24",
    "172.16.31.0/24"
  ] 
}

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

variable "ec2_type" {
  default = "t2.medium"
}

variable "ssh_key" {
  default = "kube-test"
}
