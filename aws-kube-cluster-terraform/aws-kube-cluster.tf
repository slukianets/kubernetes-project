provider "aws" {}

resource "aws_vpc" "kube-vpc" {
  cidr_block       = var.vpc_network
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.environment}-VPC"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.kube-vpc.id

  tags = {
    Name = "${var.environment}-IGW"
  }
}

resource "aws_subnet" "PublicSubnet1" {
  vpc_id     = aws_vpc.kube-vpc.id
  availability_zone_id = data.aws_availability_zones.current.zone_ids[0]
  map_public_ip_on_launch = true
  cidr_block = var.public_subnet_1

  tags = {
    Name = "${var.environment}-Public-Subnet (AZ1)"
  }
}

resource "aws_subnet" "PublicSubnet2" {
  vpc_id     = aws_vpc.kube-vpc.id
  availability_zone_id = data.aws_availability_zones.current.zone_ids[1]
  map_public_ip_on_launch = true
  cidr_block = var.public_subnet_2

  tags = {
    Name = "${var.environment}-Public-Subnet (AZ2)"
  }
}

resource "aws_subnet" "PrivateSubnet1" {
  vpc_id     = aws_vpc.kube-vpc.id
  availability_zone_id = data.aws_availability_zones.current.zone_ids[0]
  cidr_block = var.private_subnet_1

  tags = {
    Name = "${var.environment}-Private-Subnet (AZ1)"
  }
}

resource "aws_subnet" "PrivateSubnet2" {
  vpc_id     = aws_vpc.kube-vpc.id
  availability_zone_id = data.aws_availability_zones.current.zone_ids[1]
  cidr_block = var.private_subnet_2

  tags = {
    Name = "${var.environment}-Private-Subnet (AZ2)"
  }
}

resource "aws_subnet" "DBSubnet1" {
  vpc_id     = aws_vpc.kube-vpc.id
  availability_zone_id = data.aws_availability_zones.current.zone_ids[0]
  cidr_block = var.db_subnet_1

  tags = {
    Name = "${var.environment}-DB-Subnet (AZ1)"
  }
}

resource "aws_subnet" "DBSubnet2" {
  vpc_id     = aws_vpc.kube-vpc.id
  availability_zone_id = data.aws_availability_zones.current.zone_ids[1]
  cidr_block = var.db_subnet_2

  tags = {
    Name = "${var.environment}-DB-Subnet(AZ2)"
  }
}

resource "aws_eip" "eip_nat_gw_1" {
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_eip" "eip_nat_gw_2" {
  depends_on = [aws_internet_gateway.gw]
}


resource "aws_nat_gateway" "nat_gw_1" {
  allocation_id = aws_eip.eip_nat_gw_1.id
  subnet_id     = aws_subnet.PublicSubnet2.id
  depends_on = [aws_internet_gateway.gw]
  tags = {
    Name = "${var.environment}-NAT-GW-1"
  }
}

resource "aws_nat_gateway" "nat_gw_2" {
  allocation_id = aws_eip.eip_nat_gw_2.id
  subnet_id     = aws_subnet.PublicSubnet2.id
  depends_on = [aws_internet_gateway.gw]
  tags = {
    Name = "${var.environment}-NAT-GW-2"
  }
}

# Public Route Table
resource "aws_route_table" "PublicRouteTable" {
  vpc_id =aws_vpc.kube-vpc.id
  depends_on = [aws_internet_gateway.gw]
  tags = {
    Name = "${var.environment}-PublicRouteTable"
  }
}

resource "aws_route" "DefaultPublicRoute" {
  route_table_id            =  aws_route_table.PublicRouteTable.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "Association_PublicSubnet1" {
  subnet_id      = aws_subnet.PublicSubnet1.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_route_table_association" "Association_PublicSubnet2" {
  subnet_id      = aws_subnet.PublicSubnet2.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

# Private Route Table AZ1
resource "aws_route_table" "PrivateRouteTableAZ1" {
  vpc_id =aws_vpc.kube-vpc.id
  depends_on = [aws_nat_gateway.nat_gw_1]
  tags = {
    Name = "${var.environment}-PrivateRouteTableAZ1"
  }
}

resource "aws_route" "DefaultPrivateRouteAZ1" {
  route_table_id            =  aws_route_table.PrivateRouteTableAZ1.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.nat_gw_1.id
  lifecycle {
    ignore_changes = ["gateway_id"]
  }
}

resource "aws_route_table_association" "Association_PrivateSubnet1" {
  subnet_id      = aws_subnet.PrivateSubnet1.id
  route_table_id = aws_route_table.PrivateRouteTableAZ1.id

}

# Private Route Table AZ2
resource "aws_route_table" "PrivateRouteTableAZ2" {
  depends_on = [aws_nat_gateway.nat_gw_2]
  vpc_id =aws_vpc.kube-vpc.id
  tags = {
    Name = "${var.environment}PrivateRouteTableAZ2"
  }
}

resource "aws_route" "DefaultPrivateRouteAZ2" {
  route_table_id            =  aws_route_table.PrivateRouteTableAZ2.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.nat_gw_2.id
  lifecycle {
    ignore_changes = ["gateway_id"]
  }
}

resource "aws_route_table_association" "Association_PrivateSubnet2" {
  subnet_id      = aws_subnet.PrivateSubnet2.id
  route_table_id = aws_route_table.PrivateRouteTableAZ2.id

}

#DB subnet
resource "aws_route_table" "DBRouteTable" {
  vpc_id =aws_vpc.kube-vpc.id
  tags = {
    Name = "${var.environment}-DBRouteTable"
  }
}

resource "aws_route_table_association" "Association_DBSubnet1" {
  subnet_id      = aws_subnet.DBSubnet1.id
  route_table_id = aws_route_table.DBRouteTable.id
}

resource "aws_route_table_association" "Association_DBSubnet2" {
  subnet_id      = aws_subnet.DBSubnet2.id
  route_table_id = aws_route_table.DBRouteTable.id
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
      cidr_blocks = ["${aws_vpc.kube-vpc.cidr_block}"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = aws_vpc.kube-vpc.id
  depends_on = [aws_route_table.PublicRouteTable, aws_route_table.PrivateRouteTableAZ1, aws_route_table.PrivateRouteTableAZ1, aws_route_table.DBRouteTable]
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
      cidr_blocks = ["${aws_vpc.kube-vpc.cidr_block}"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = aws_vpc.kube-vpc.id
  depends_on = [aws_route_table.PublicRouteTable, aws_route_table.PrivateRouteTableAZ1, aws_route_table.PrivateRouteTableAZ1, aws_route_table.DBRouteTable]
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
  vpc_id = aws_vpc.kube-vpc.id
  depends_on = [aws_route_table.PublicRouteTable, aws_route_table.PrivateRouteTableAZ1, aws_route_table.PrivateRouteTableAZ1, aws_route_table.DBRouteTable]
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
  vpc_id = aws_vpc.kube-vpc.id
  depends_on = [aws_route_table.PublicRouteTable, aws_route_table.PrivateRouteTableAZ1, aws_route_table.PrivateRouteTableAZ1, aws_route_table.DBRouteTable]
  tags = {
    Name = "ssh security group"
  }
}

resource "aws_instance" "kube-cluster-master" {
  count = 1
  ami           = data.aws_ami.ubuntu_latest.image_id
  instance_type = var.ec2_type
  key_name      = var.ssh_key
  subnet_id = aws_subnet.PublicSubnet1.id
  vpc_security_group_ids = [aws_security_group.kubernetes_sg.id, aws_security_group.weave_net_sg.id, aws_security_group.ssh_for_my_ip_sg.id]
  user_data = templatefile("user_data.sh.tpl", {name = "k8s-master"})
  depends_on = [aws_security_group.kubernetes_sg, aws_security_group.weave_net_sg, aws_security_group.http_https_sg, aws_security_group.ssh_for_my_ip_sg]
  tags = {
      Name = "Kubernetes-Master${count.index + 1}"
      Kube-Role = "Master"
    }
  root_block_device {
      volume_size = 15
    }
}

resource "aws_instance" "kube-cluster-node" {
  count = 2
  ami           = data.aws_ami.ubuntu_latest.image_id
  instance_type = var.ec2_type
  key_name      = var.ssh_key
  subnet_id  = "aws_subnet.PublicSubnet${count.index + 1}.id"
  vpc_security_group_ids = [aws_security_group.kubernetes_sg.id, aws_security_group.weave_net_sg.id, aws_security_group.http_https_sg.id, aws_security_group.ssh_for_my_ip_sg.id]
  user_data = templatefile("user_data.sh.tpl", {name = "k8s-node0${count.index + 1}"})
  depends_on = [aws_security_group.kubernetes_sg, aws_security_group.weave_net_sg, aws_security_group.http_https_sg, aws_security_group.ssh_for_my_ip_sg]
  tags = {
      Name = "Kubernetes-Node0${count.index + 1}"
      Kube-Role = "Node"
    }
  root_block_device {
      volume_size = 15
    }
}
