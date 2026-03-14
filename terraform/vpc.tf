resource "aws_vpc" "app_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name      = "${var.project_name}-vpc"
    Component = "networking"
  }
}

# Pub Subnet
resource "aws_subnet" "public_sub" {
  count                   = 2
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name      = "${var.project_name}-pub-${count.index + 1}"
    Component = "networking"
    Tier      = "public"
  }
}

# Pvt Subnet
resource "aws_subnet" "private_sub" {
  count             = 2
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name      = "${var.project_name}-pvt-${count.index + 1}"
    Component = "networking"
    Tier      = "private"
  }
}

# IGW
resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name      = "${var.project_name}-igw"
    Component = "networking"
  }
}

# NAT Elastic IP
resource "aws_eip" "app_nat_eip" {
  count  = 2
  domain = "vpc"

  tags = {
    Name      = "${var.project_name}-nat-eip-${count.index + 1}"
    Component = "networking"
  }
}

resource "aws_nat_gateway" "app_nat" {
  count         = 2
  allocation_id = aws_eip.app_nat_eip[count.index].id
  subnet_id     = aws_subnet.public_sub[count.index].id

  tags = {
    Name      = "${var.project_name}-nat-${count.index + 1}"
    Component = "networking"
  }

  depends_on = [aws_internet_gateway.app_igw]
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_igw.id
  }

  tags = {
    Name      = "${var.project_name}-pub-rt"
    Component = "networking"
  }
}

resource "aws_route_table" "private_rt" {
  count  = 2
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.app_nat[count.index].id
  }

  tags = {
    Name      = "${var.project_name}-pvt-rt-${count.index + 1}"
    Component = "networking"
  }
}

resource "aws_route_table_association" "pub" {
  count          = 2
  subnet_id      = aws_subnet.public_sub[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "pvt" {
  count          = 2
  subnet_id      = aws_subnet.private_sub[count.index].id
  route_table_id = aws_route_table.private_rt[count.index].id
}
