data "aws_availability_zones" "current" {}

data "external" "my_ip" {
  program = ["/bin/bash", "${path.root}/my_ip.sh"]
}

data "aws_ami"  "ubuntu_latest" {
  owners = ["099720109477"]
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}
