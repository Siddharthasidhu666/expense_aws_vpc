resource "aws_vpc_peering_connection" "foo" {
  count       = var.is_peering_required ? 1 : 0
  peer_vpc_id = var.acceptor_vpc == " " ? data.aws_vpc.default.id : var.acceptor_vpc
  vpc_id      = aws_vpc.main.id
  auto_accept = var.acceptor_vpc == " " ? true : false
  tags = merge(var.common_tags, var.peering_tags,
    {
      Name = local.resource_name
    }
  )
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_route" "public_peering" {
  route_table_id            = aws_route_table.public_route.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.foo[0].id
}

resource "aws_route" "private_peering" {
  route_table_id            = aws_route_table.private_route.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.foo[0].id
}


resource "aws_route" "database_peering" {
  route_table_id            = aws_route_table.database_route.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.foo[0].id
}

resource "aws_route" "default_peering" {
  route_table_id            = data.aws_vpc.default.main_route_table_id
  destination_cidr_block    = var.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.foo[0].id
}
