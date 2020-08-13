provider "aws" {}


data "aws_ami"  "ubuntu_latest" {
  owners = ["099720109477"]
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

data "aws_ami"  "amazon_linux_latest" {
  owners = ["amazon"]
  most_recent = true
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_ami"  "windows_server_2019_base_latest" {
  owners = ["amazon"]
  most_recent = true
  filter {
    name = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }
}


# Info about Ubuntu
output "ami_id_ubuntu_latest" {
  value = data.aws_ami.ubuntu_latest.image_id
}
output "name_ubuntu_latest" {
  value = data.aws_ami.ubuntu_latest.name
}
# Info about Amazon Linux
output "ami_id_amazon_linux_latest" {
  value = data.aws_ami.amazon_linux_latest.image_id
}
output "name_amazon_linux_latest" {
  value = data.aws_ami.amazon_linux_latest.name
}
# Info about Windows Server 2019 Base
output "ami_id_windows_server_2019_base_latest" {
  value = data.aws_ami.windows_server_2019_base_latest.image_id
}
output "name_windows_server_2019_base_latestt" {
  value = data.aws_ami.windows_server_2019_base_latest.name
}
