output "vpc" {
  value = map(
    aws_vpc.kube-vpc.tags["Name"], aws_vpc.kube-vpc.id
  )
}

output igw {
  value  = map (
    aws_internet_gateway.gw.tags["Name"], aws_internet_gateway.gw.id
  )
}

output "public_subnet1" {
  value = map(
    aws_subnet.PublicSubnet1.tags["Name"], aws_subnet.PublicSubnet1.id
  )
}
output "public_subnet2" {
  value = map(
    aws_subnet.PublicSubnet2.tags["Name"], aws_subnet.PublicSubnet2.id
  )
}

output "private_subnet1" {
  value = map(
    aws_subnet.PrivateSubnet1.tags["Name"], aws_subnet.PrivateSubnet1.id
  )
}

output "private_subnet2" {
  value = map(
    aws_subnet.PrivateSubnet2.tags["Name"], aws_subnet.PrivateSubnet2.id
  )
}

output "db_subnet1" {
  value = map(
    aws_subnet.DBSubnet1.tags["Name"], aws_subnet.DBSubnet1.id
  )
}

output "db_subnet2" {
  value = map(
    aws_subnet.DBSubnet2.tags["Name"], aws_subnet.DBSubnet2.id
  )
}

output "nat_gw_1" {
  value = map (
    aws_nat_gateway.nat_gw_1.tags["Name"], list (aws_nat_gateway.nat_gw_1.id, aws_nat_gateway.nat_gw_1.public_ip)
  )
}

output "nat_gw_2" {
  value = map (
    aws_nat_gateway.nat_gw_2.tags["Name"], list (aws_nat_gateway.nat_gw_2.id, aws_nat_gateway.nat_gw_2.public_ip)
  )
}

output "public_route_table" {
  value = map (
    aws_route_table.PublicRouteTable.tags["Name"], aws_route_table.PublicRouteTable.id
  )
}

output "private_route_table_az1" {
  value = map (
    aws_route_table.PrivateRouteTableAZ1.tags["Name"], aws_route_table.PrivateRouteTableAZ1.id
  )
}

output "private_route_table_az2" {
  value = map (
    aws_route_table.PrivateRouteTableAZ2.tags["Name"], aws_route_table.PrivateRouteTableAZ2.id
  )
}

output "db_route_table" {
  value = map (
    aws_route_table.DBRouteTable.tags["Name"], aws_route_table.DBRouteTable.id
  )
}

output "kubernetes_sg" {
  value = map (
    aws_security_group.kubernetes_sg.tags["Name"], aws_security_group.kubernetes_sg.id
  )
}

output "weave_net_sg" {
  value = map (
    aws_security_group.weave_net_sg.tags["Name"], aws_security_group.weave_net_sg.id
  )
}

output "http_https_sg" {
  value = map (
    aws_security_group.http_https_sg.tags["Name"], aws_security_group.http_https_sg.id
  )
}

output "ssh_for_my_ip_sg" {
  value = map (
    aws_security_group.ssh_for_my_ip_sg.tags["Name"], aws_security_group.ssh_for_my_ip_sg.id
  )
}

output "master_ip" {
  value = aws_instance.kube-cluster-master[*].public_ip
}

output "node_ip" {
  value = aws_instance.kube-cluster-node[*].public_ip
}

output "dns_alb" {
  value = aws_lb.kube_alb.dns_name
}
