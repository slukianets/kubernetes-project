provider "aws" {}

# Create VPC
resource "aws_vpc" "kube_vpc" {
  cidr_block       = var.vpc_network
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.environment}-VPC"
  }
}

#Create Internet gateway with EIP
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.kube_vpc.id

  tags = {
    Name = "${var.environment}-IGW"
  }
}

#Create Subnets
resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnets)
  vpc_id     = aws_vpc.kube_vpc.id
  availability_zone_id = data.aws_availability_zones.current.zone_ids[count.index]
  map_public_ip_on_launch = true
  cidr_block = element(var.public_subnets, count.index)

  tags = {
    Name = "${var.environment}-Public-Subnet (AZ${count.index + 1})"
  }
}

resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnets)
  vpc_id     = aws_vpc.kube_vpc.id
  availability_zone_id = data.aws_availability_zones.current.zone_ids[count.index]
  cidr_block = element(var.private_subnets, count.index)

  tags = {
    Name = "${var.environment}-Private-Subnet (AZ${count.index + 1})"
  }
}

resource "aws_subnet" "db_subnets" {
  count = length(var.db_subnets)
  vpc_id     = aws_vpc.kube_vpc.id
  availability_zone_id = data.aws_availability_zones.current.zone_ids[count.index]
  cidr_block = element(var.db_subnets, count.index)

  tags = {
    Name = "${var.environment}-DB-Subnet (AZ${count.index + 1})"
  }
}


#Create EIP for NAT gateways
resource "aws_eip" "eip_nat_gws" {
  count = length(aws_subnet.private_subnets[*].id)
  depends_on = [aws_internet_gateway.igw]
}


#Create NAT gateways
resource "aws_nat_gateway" "nat_gws" {
  count = length(aws_subnet.private_subnets[*].id)
  allocation_id = aws_eip.eip_nat_gws[count.index].id
  subnet_id     = aws_subnet.private_subnets[count.index].id
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "${var.environment}-NAT-GW-${count.index + 1}"
  }
}

# Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id =aws_vpc.kube_vpc.id
  depends_on = [aws_internet_gateway.igw]
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.environment}-PublicRouteTable"
  }
}

resource "aws_route_table_association" "association_public_subnets" {
  count = length(aws_subnet.public_subnets[*].id)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Private Route Table AZ
resource "aws_route_table" "private_route_tables" {
  count = length(aws_subnet.private_subnets[*].id)
  vpc_id =aws_vpc.kube_vpc.id
  depends_on = [aws_nat_gateway.nat_gws]
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gws[count.index].id
  }

  tags = {
    Name = "${var.environment}-PrivateRouteTableAZ${count.index + 1}"
  }
}

resource "aws_route_table_association" "association_private_subnets" {
  count = length(aws_subnet.private_subnets[*].id)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_tables[count.index].id
}

#DB Route Table
resource "aws_route_table" "db_route_table" {
  vpc_id =aws_vpc.kube_vpc.id
  tags = {
    Name = "${var.environment}-DBRouteTable"
  }
}

resource "aws_route_table_association" "association_db_subnets" {
  count = length(aws_subnet.db_subnets[*].id)
  subnet_id      = aws_subnet.db_subnets[count.index].id
  route_table_id = aws_route_table.db_route_table.id
}

#Create Security Groups with Kubernetes, Weave, HTTPS, HTTP and SSH ports  
resource "aws_security_group" "kubernetes_sg" {
  name = "Kubernetes security group"

  dynamic "ingress" {
    for_each = var.ec2_ingress_port_kube
    content {
      from_port = ingress.value[0]
      to_port = ingress.value[1]
      protocol = "tcp"
      description = ingress.value[2]
      cidr_blocks = ["${aws_vpc.kube_vpc.cidr_block}"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = aws_vpc.kube_vpc.id
  depends_on = [
    aws_route_table.public_route_table, 
    aws_route_table.private_route_tables,  
    aws_route_table.db_route_table
    ]
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
      cidr_blocks = ["${aws_vpc.kube_vpc.cidr_block}"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = aws_vpc.kube_vpc.id
  depends_on = [
    aws_route_table.public_route_table, 
    aws_route_table.private_route_tables,  
    aws_route_table.db_route_table
    ]
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
  vpc_id = aws_vpc.kube_vpc.id
  depends_on = [
     aws_route_table.public_route_table,
     aws_route_table.private_route_tables,
     aws_route_table.db_route_table
     ]
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
  vpc_id = aws_vpc.kube_vpc.id
  depends_on = [
    aws_route_table.public_route_table, 
    aws_route_table.private_route_tables,
    aws_route_table.db_route_table
    ]
  tags = {
    Name = "ssh security group"
  }
}

#Create Master for Kubernetes
resource "aws_instance" "kube_cluster_master" {
  count = 1
  ami           = data.aws_ami.ubuntu_latest.image_id
  instance_type = var.ec2_type
  key_name      = var.ssh_key
  subnet_id = aws_subnet.public_subnets[count.index].id
  vpc_security_group_ids = [
    aws_security_group.kubernetes_sg.id, 
    aws_security_group.weave_net_sg.id, 
    aws_security_group.ssh_for_my_ip_sg.id
    ]
  user_data = templatefile("user_data.sh.tpl", {name = "k8s-master"})
  depends_on = [
    aws_security_group.kubernetes_sg, 
    aws_security_group.weave_net_sg, 
    aws_security_group.http_https_sg, 
    aws_security_group.ssh_for_my_ip_sg
    ]
  tags = {
      Name = "Kubernetes-Master${count.index + 1}"
      Kube-Role = "Master"
    }
  root_block_device {
      volume_size = 15
    }
}

#Create Nodes for Kuberneetes
resource "aws_instance" "kube_cluster_node" {
  count = 2
  ami           = data.aws_ami.ubuntu_latest.image_id
  instance_type = var.ec2_type
  key_name      = var.ssh_key
  subnet_id  = aws_subnet.public_subnets[count.index].id
  vpc_security_group_ids = [
    aws_security_group.kubernetes_sg.id, 
    aws_security_group.weave_net_sg.id, 
    aws_security_group.http_https_sg.id, 
    aws_security_group.ssh_for_my_ip_sg.id
    ]
  user_data = templatefile("user_data.sh.tpl", {name = "k8s-node0${count.index + 1}"})
  depends_on = [
    aws_security_group.kubernetes_sg, 
    aws_security_group.weave_net_sg, 
    aws_security_group.http_https_sg, 
    aws_security_group.ssh_for_my_ip_sg
    ]
  tags = {
      Name = "Kubernetes-Node0${count.index + 1}"
      Kube-Role = "Node"
    }
  root_block_device {
      volume_size = 15
    }
}

#Create Target Group
resource "aws_lb_target_group" "kube_cluster_ec2_tg" {
  name     = "kube-cluster-ec2-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.kube_vpc.id
  health_check {
    enabled = true
    interval = 5
    timeout = 3
    healthy_threshold = 3
    unhealthy_threshold = 5
    matcher = "200,302"
    path = "/"
  }
  depends_on = [aws_instance.kube_cluster_node]
}

resource "aws_lb_target_group_attachment" "tg_add_ec2" {
  count = 2
  target_group_arn = aws_lb_target_group.kube_cluster_ec2_tg.arn
  target_id        = aws_instance.kube_cluster_node[count.index].id
  port             = 80
  depends_on = [aws_lb_target_group.kube_cluster_ec2_tg]
}

#Create Application Load Balancer 
resource "aws_lb" "kube_alb" {
  name               = "Kube-Cluster-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.http_https_sg.id]
  subnets = [for sn in aws_subnet.public_subnets[*] : sn.id]
  depends_on = [aws_lb_target_group.kube_cluster_ec2_tg]

  tags = {
    Name = "${var.environment}-ALB"
  }
}

resource "aws_lb_listener" "kube_front_end" {
  load_balancer_arn = aws_lb.kube_alb.arn
  port              = "80"
  protocol          = "HTTP"
  
  depends_on = [aws_lb.kube_alb]
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kube_cluster_ec2_tg.arn
  }
}