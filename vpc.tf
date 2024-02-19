provider "aws" {
    region = "eu-north-1"
}

resource "aws_vpc" "my_vpc" {
    cidr_block = "192.168.0.0/16"

    tags = {
        Name = "my-vpc-new"
    }
}


resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "192.168.0.0/24"
    map_public_ip_on_launch = true

    tags = {
        Name = "public-subnet"
    }
}

resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "192.168.16.0/24"

    tags = {
        Name = "private-subnet"
    }
}

resource "aws_internet_gateway" "my_igw" {
    vpc_id = aws_vpc.my_vpc.id

    tags = {
        Name = "my-igw"
    }
}

resource "aws_route" "my_route" {
    route_table_id = aws_vpc.my_vpc.default_route_table_id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id

   }

resource "aws_eip" "my_eip" {
    domain = "vpc"
}

resource "aws_nat_gateway" "my_nat" {
    allocation_id = aws_eip.my_eip.id
    subnet_id     = aws_subnet.public_subnet.id

    tags = {
        Name = "my-nat"
    }
}

resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.my_vpc.id

    route  {
        gateway_id = aws_nat_gateway.my_nat.id
        cidr_block = "0.0.0.0/0"
    }
}

resource "aws_route_table_association" "my_association" {
   route_table_id = aws_route_table.private_route_table.id
   subnet_id = aws_subnet.public_subnet.id
  }

resource "aws_security_group" "my_security" {
  description = "allow http"
  vpc_id = aws_vpc.my_vpc.id 
  
  egress  {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
   }
  

 ingress  {
   from_port = 80
   protocol = "tcp"
   to_port = 80
   cidr_blocks = ["0.0.0.0/0"]
  }
   
  tags = {
     Name = "my-sg-new"
 }
}
  
