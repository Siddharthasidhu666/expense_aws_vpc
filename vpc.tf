resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(var.common_tags, var.vpc_tags,
    {
      Name = local.resource_name
    }
  )
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, var.igw_tags,
    {
      Name = "${local.resource_name}-igw"
    }
  )
}

resource "aws_subnet" "public-subnet" {
  vpc_id                  = aws_vpc.main.id
  count                   = length(var.public_cidr_blocks)
  cidr_block              = var.public_cidr_blocks[count.index]
  availability_zone       = local.az[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, var.public_subnet_tags,
    {
      Name = "${local.resource_name}-public-${local.az[count.index]}"
    }
  )
}

data "aws_availability_zones" "available" {
  state = "available" # Filters only the AZs that are currently available
}

resource "aws_subnet" "private-subnet" {
  vpc_id            = aws_vpc.main.id
  count             = length(var.private_cidr_blocks)
  cidr_block        = var.private_cidr_blocks[count.index]
  availability_zone = local.az[count.index]

  tags = merge(var.common_tags, var.private_subnet_tags,
    {
      Name = "${local.resource_name}-private-${local.az[count.index]}"
    }
  )
}

resource "aws_subnet" "database-subnet" {
  vpc_id            = aws_vpc.main.id
  count             = length(var.database_cidr_blocks)
  cidr_block        = var.database_cidr_blocks[count.index]
  availability_zone = local.az[count.index]

  tags = merge(var.common_tags, var.database_subnet_tags,
    {
      Name = "${local.resource_name}-database-${local.az[count.index]}"
    }
  )
}

resource "aws_eip" "lb" {
  domain = "vpc"
  tags = merge(var.common_tags, var.eip_tags,
    {
      Name = "${local.resource_name}"
    }
  )
}

resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.public-subnet[0].id

  tags = merge(var.common_tags, var.nat_tags,
    {
      Name = "${local.resource_name}-nat"
    }
  )
  depends_on = [aws_internet_gateway.gw]
}


resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = merge(var.common_tags, var.nat_tags,
    {
      Name = "${local.resource_name}-public"
    }
  )

}

resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.example.id
  }
  tags = merge(var.common_tags, var.nat_tags,
    {
      Name = "${local.resource_name}-private"
    }
  )
}

resource "aws_route_table" "database_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.example.id
  }
  tags = merge(var.common_tags, var.nat_tags,
    {
      Name = "${local.resource_name}-database"
    }
  )
}


resource "aws_route_table_association" "public_association" {
  count          = 2
  subnet_id      = aws_subnet.public-subnet[count.index].id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "private_association" {
  count          = 2
  subnet_id      = aws_subnet.private-subnet[count.index].id
  route_table_id = aws_route_table.private_route.id
}


resource "aws_route_table_association" "database_association" {
  count          = 2
  subnet_id      = aws_subnet.database-subnet[count.index].id
  route_table_id = aws_route_table.database_route.id
}


resource "aws_db_subnet_group" "group" {
  name       = local.resource_name
  subnet_ids = aws_subnet.database-subnet[*].id

  tags = {
    Name = "My DB subnet group"
  }
}
