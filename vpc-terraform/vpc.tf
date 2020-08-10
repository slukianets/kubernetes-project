provider "aws" {}

data "aws_availability_zones" "current" {}

resource "aws_vpc" "kube-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "Kube-Cluster-VPC"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.kube-vpc.id

  tags = {
    Name = "Kube-Cluster-IGW"
  }
}

resource "aws_subnet" "PublicSubnet1" {
  vpc_id     = aws_vpc.kube-vpc.id
  availability_zone_id = data.aws_availability_zones.current.zone_ids[0]
  map_public_ip_on_launch = true
  cidr_block = "10.0.10.0/24"

  tags = {
    Name = "Kube-Cluster-Public-Subnet (AZ1)"
  }
}

resource "aws_subnet" "PublicSubnet2" {
  vpc_id     = aws_vpc.kube-vpc.id
  availability_zone_id = data.aws_availability_zones.current.zone_ids[1]
  map_public_ip_on_launch = true
  cidr_block = "10.0.11.0/24"

  tags = {
    Name = "Kube-Cluster-Public-Subnet (AZ2)"
  }
}

resource "aws_subnet" "PrivateSubnet1" {
  vpc_id     = aws_vpc.kube-vpc.id
  availability_zone_id = data.aws_availability_zones.current.zone_ids[0]
  cidr_block = "10.0.20.0/24"

  tags = {
    Name = "Kube-Cluster-Private-Subnet (AZ1)"
  }
}

resource "aws_subnet" "PrivateSubnet2" {
  vpc_id     = aws_vpc.kube-vpc.id
  availability_zone_id = data.aws_availability_zones.current.zone_ids[1]
  cidr_block = "10.0.21.0/24"

  tags = {
    Name = "Kube-Cluster-Private-Subnet (AZ2)"
  }
}

resource "aws_subnet" "DBSubnet1" {
  vpc_id     = aws_vpc.kube-vpc.id
  availability_zone_id = data.aws_availability_zones.current.zone_ids[0]
  cidr_block = "10.0.30.0/24"

  tags = {
    Name = "Kube-Cluster-DB-Subnet (AZ1)"
  }
}

resource "aws_subnet" "DBSubnet2" {
  vpc_id     = aws_vpc.kube-vpc.id
  availability_zone_id = data.aws_availability_zones.current.zone_ids[1]
  cidr_block = "10.0.31.0/24"

  tags = {
    Name = "Kube-Cluster-DB-Subnet(AZ2)"
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
    Name = "Kube-Cluster-NAT-GW-1"
  }
}

resource "aws_nat_gateway" "nat_gw_2" {
  allocation_id = aws_eip.eip_nat_gw_2.id
  subnet_id     = aws_subnet.PublicSubnet2.id
  depends_on = [aws_internet_gateway.gw]
  tags = {
    Name = "Kube-Cluster-NAT-GW-2"
  }
}

# Public Route Table
resource "aws_route_table" "PublicRouteTable" {
  vpc_id =aws_vpc.kube-vpc.id
  depends_on = [aws_internet_gateway.gw]
  tags = {
    Name = "Kube-Cluster-PublicRouteTable"
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
    Name = "Kube-Cluster-PrivateRouteTableAZ1"
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
    Name = "Kube-Cluster-PrivateRouteTableAZ2"
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
    Name = "Kube-Cluster-DBRouteTable"
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
