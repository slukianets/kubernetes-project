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
  value = map(
    aws_subnet.public_subnets[*].tags["Name"], aws_subnet.public_subnets[*].id
  )
}

output "private_subnets" {
  value = map(
    aws_subnet.private_subnets[*].tags["Name"], aws_subnet.private_subnets[*].id
  )
}

output "db_subnets" {
  value = map(
    aws_subnet.db_subnets[*].tags["Name"], aws_subnet.db_subnets[*].id
  )
}

output "nat_gws" {
  value = map (
    aws_nat_gateway.nat_gws[*].tags["Name"], list (aws_nat_gateway.nat_gws[*].id, aws_nat_gateway.nat_gws[*].public_ip)
  )
}

output "public_route_table" {
  value = map (
    aws_route_table.public_route_table.tags["Name"], aws_route_table.public_route_table.id
  )
}

output "private_route_tables" {
  value = map (
    aws_route_table.private_route_tables[*].tags["Name"], aws_route_table.private_route_tables[*].id
  )
}

output "db_route_table" {
  value = map (
    aws_route_table.db_route_table.tags["Name"], aws_route_table.db_route_table.id
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
  value = aws_instance.kube_cluster_master[*].public_ip
}

output "node_ip" {
  value = aws_instance.kube_cluster_node[*].public_ip
}

#output "dns_alb" {
#  value = aws_lb.kube_alb.dns_name
#}
