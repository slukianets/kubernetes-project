provider "aws" {}


#"s3:PutObject"

data "aws_ami"  "ubuntu_latest" {
  owners = ["099720109477"]
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

variable "ec2_type" {
  default = "t2.micro"
}

variable "ssh_key" {
  default = "kube-test"
}


resource "aws_iam_role" "s3_iam_role" {
    name = "s3_iam_role"

    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "s3_readonly_role_policy" {
    name = "s3_readonly_role_policy"
    role = aws_iam_role.s3_iam_role.id 
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "my",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:ListAllMyBuckets",
                "s3:ListBucket",
                "s3:HeadBucket"
           
                
            ],
            "Resource": "arn:aws:s3:::*"
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "s3_iam_profile" {
    name = "s3_iam_profile"
    role = "s3_iam_role"
}

resource "aws_instance" "ec2_with_role" {
  count = 1
  ami           = data.aws_ami.ubuntu_latest.image_id
  instance_type = var.ec2_type
  key_name      = var.ssh_key
  iam_instance_profile = aws_iam_instance_profile.s3_iam_profile.id
  
  tags = {
      Name = "EC2-with-Role"
      
    }
  
}