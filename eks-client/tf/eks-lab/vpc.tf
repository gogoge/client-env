resource "aws_vpc" "main" {  
  cidr_block = local.vpc_cidr

  tags = {
    "Name" = "Hackathon"
  }
}


resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.public_subnet_1_cidr
  availability_zone = local.az1
  map_public_ip_on_launch = true

  tags = {
    "kubernetes.io/role/elb" = "1"
    "Name" = "Hackathon - Public 1"
  }
}


resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.public_subnet_2_cidr
  availability_zone = local.az2
  map_public_ip_on_launch = true

  tags = {
    "kubernetes.io/role/elb" = "1"
    "Name" = "Hackathon - Public 2"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.private_subnet_1_cidr
  availability_zone = local.az1

  tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "Name" = "Hackathon - Private 1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.private_subnet_2_cidr
  availability_zone = local.az2

  tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "Name" = "Hackathon - Private 2"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Hackathon - Public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Hackathon - Private"
  }
}



resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}


resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# remove route in default route
resource "aws_default_route_table" "main" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route = []

  tags = {
    Name = "Hackathon - vpc default"
  }
}
