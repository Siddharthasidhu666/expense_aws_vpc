output "azs" {
  value = data.aws_availability_zones.available

}

output "vpc_id" {
  value = aws_vpc.main.id

}

output "public_subnet_ids" {
  value = aws_subnet.public-subnet[*].id

}

output "private_subnet_ids" {
  value = aws_subnet.private-subnet[*].id

}

output "database_subnet_ids" {
  value = aws_subnet.database-subnet[*].id

}

output "db_subnet_group_name" {
    value = aws_db_subnet_group.group.name
  
}