#create vpc with the help of terraform

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  
  tags = {
    Name = "terraform-vpc"
  }
}

#public subnet for my vpc---

resource "aws_subnet" "public_subnet" {
  vpc_id      = aws_vpc.main.id
  cidr_block  = "10.0.0.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "Public Subnet"
  }
}

#public subnet for my vpc---

resource "aws_subnet" "public_subnet1" {
  vpc_id      = aws_vpc.main.id
  cidr_block  = "10.0.1.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "Public Subnet1"
  }
}


#private subnet for my vpc for my vpc---

resource "aws_subnet" "private_subnet" {
  vpc_id      = aws_vpc.main.id
  cidr_block  = "10.0.2.0/24"
  availability_zone = "ap-south-1a"

  

  tags = {
    Name = "Private Subnet"
  }
}

#private subnet for my vpc for my vpc---

resource "aws_subnet" "private_subnet1" {
  vpc_id      = aws_vpc.main.id
  cidr_block  = "10.0.3.0/24"
  availability_zone = "ap-south-1b"

  

  tags = {
    Name = "Private Subnet1"
  }
}

#create internet gateway for my vpc---

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "my-igw"
  }
}

#create NAT gateway for my vpc---

resource "aws_nat_gateway" "NAT-gw" {
  allocation_id = aws_eip.NAT-gw-eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "gw NAT"
  }
}

#create eip for my vpc--

resource "aws_eip" "NAT-gw-eip" {
  vpc = true
}




#create route-table for public subnet---

resource "aws_route_table" "publicRT" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block  = "0.0.0.0/0"
    gateway_id  = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.publicRT.id
}

#create route-table for private subnet---

resource "aws_route_table" "privateRT" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block  = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.NAT-gw.id
  }

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.privateRT.id
}


