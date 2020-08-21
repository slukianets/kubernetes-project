
output "vpc" {
  value = map(
    aws_vpc.kube_vpc.tags["Name"], aws_vpc.kube_vpc.id
  )
}

output igw {
  value  = map (
    aws_internet_gateway.igw.tags["Name"], aws_internet_gateway.igw.id
  )
}

output "public_subnets" {
  value = {
    for sn in aws_subnet.public_subnets[*] : sn.tags["Name"] => sn.id
  }
}

output "private_subnets" {
  value = {
    for sn in aws_subnet.private_subnets[*] : sn.tags["Name"] => sn.id
  }
}

output "db_subnets" {
  value = {
    for sn in aws_subnet.db_subnets[*] : sn.tags["Name"] => sn.id
  }
}

output "nat_gws" {
  value = {
    for nat in aws_nat_gateway.nat_gws[*]: nat.tags["Name"]  => [nat.id, nat.public_ip]
  }
}

output "public_route_table" {
  value = {  
    for rt in aws_route_table.public_route_table[*]: rt.tags["Name"] => rt.id
  }
}

output "private_route_tables" {
  value = {  
    for rt in aws_route_table.private_route_tables[*]: rt.tags["Name"] => rt.id
  }
}

output "db_route_table" {
  value = {  
    for rt in aws_route_table.db_route_table[*]: rt.tags["Name"] => rt.id
  }
}

output "kubernetes_sg" {
  value = {
    for sg in aws_security_group.kubernetes_sg[*]: sg.tags["Name"] => sg.id
  }
}

output "weave_net_sg" {
  value = {
    for sg in aws_security_group.weave_net_sg[*]: sg.tags["Name"] => sg.id
  }
}

output "http_https_sg" {
  value = {
    for sg in aws_security_group.http_https_sg[*]: sg.tags["Name"] => sg.id
  }
}

output "ssh_for_my_ip_sg" {
  value = {
    for sg in aws_security_group.ssh_for_my_ip_sg[*]: sg.tags["Name"] => sg.id
  }
}

output "master_ip" {
  value = aws_instance.kube_cluster_master[*].public_ip
}

output "node_ip" {
  value = aws_instance.kube_cluster_node[*].public_ip
}

output "dns_alb" {
  value = aws_lb.kube_alb.dns_name
}


