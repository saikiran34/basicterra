#Create the VPC

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {                # Creating VPC here
  cidr_block           = var.main_vpc_cidr # Defining the CIDR block use 10.0.0.0/24 for demo
  enable_dns_hostnames = true
  tags = {
    "Name" = "${var.project_name}-${terraform.workspace}" 
  }
}

# Create a Private Subnet                   # Creating Private Subnets
resource "aws_subnet" "private1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet1 # CIDR block of private subnet1
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
  tags = {
    "Name" = "${var.project_name}-private1-${terraform.workspace}"
  }
}
resource "aws_subnet" "private2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet2 # CIDR block of private subnet2
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false
  tags = {
    "Name" = "${var.project_name}-private2-${terraform.workspace}"
  }
}
resource "aws_subnet" "private3" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet3 # CIDR block of private subnets3
  availability_zone       = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = false
  tags = {
    "Name" = "${var.project_name}-private3-${terraform.workspace}"
  }
}

#Create a Public Subnets.
resource "aws_subnet" "public_subnet1" { # Creating Public Subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet1 # CIDR block of public subnets
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = {
    "Name" = "${var.project_name}-public1-${terraform.workspace}"
  }
}
resource "aws_subnet" "public_subnet2" { # Creating Public Subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet2 # CIDR block of public subnets
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    "Name" = "${var.project_name}-public2-${terraform.workspace}"
  }
}


#Route table for Public Subnet's
resource "aws_route_table" "Fxlink_Public1_RT" { # Creating RT for Public Subnet
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0" # Traffic from Public Subnet reaches Internet via Internet Gateway
    gateway_id = aws_internet_gateway.IGW.id
  }
  tags = {
    "Name" = "${var.project_name}-Public1-RT-${terraform.workspace}"
  }
}
resource "aws_route_table" "Fxlink_Public2_RT" { # Creating RT for Public Subnet
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0" # Traffic from Public Subnet reaches Internet via Internet Gateway
    gateway_id = aws_internet_gateway.IGW.id
  }
  tags = {
    "Name" = "${var.project_name}-Public2-RT-${terraform.workspace}"
  }
}


#Route table for Private Subnet's
resource "aws_route_table" "Fxlink_Private1_RT" { # Creating RT for Private Subnet
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0" # Traffic from Private Subnet reaches Internet via NAT Gateway
    nat_gateway_id = aws_nat_gateway.NATgw.id
  }
  tags = {
    "Name" = "${var.project_name}-Private1-RT-${terraform.workspace}"
  }

}
resource "aws_route_table" "Fxlink_Private2_RT" { # Creating RT for Private Subnet
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0" # Traffic from Private Subnet reaches Internet via NAT Gateway
    nat_gateway_id = aws_nat_gateway.NATgw.id
  }
  tags = {
    "Name" = "${var.project_name}-Private2-RT-${terraform.workspace}"
  }
}
resource "aws_route_table" "Fxlink_Private3_RT" { # Creating RT for Private Subnet
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0" # Traffic from Private Subnet reaches Internet via NAT Gateway
    nat_gateway_id = aws_nat_gateway.NATgw.id
  }
  tags = {
    "Name" = "${var.project_name}-Private3-RT-${terraform.workspace}"
  }
}

#Route table Association with Public Subnet's
resource "aws_route_table_association" "Fxlink_Public1_RT_association" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.Fxlink_Public1_RT.id
}

resource "aws_route_table_association" "Fxlink_Public2_RT_association" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.Fxlink_Public2_RT.id
}

#Route table Association with Private Subnet's
resource "aws_route_table_association" "Fxlink_Private1_RT_association" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.Fxlink_Private1_RT.id
}
resource "aws_route_table_association" "Fxlink_Private2_RT_association" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.Fxlink_Private2_RT.id
}
resource "aws_route_table_association" "Fxlink_Private3_RT_association" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.Fxlink_Private3_RT.id
}

#Create Internet Gateway and attach it to VPC
resource "aws_internet_gateway" "IGW" { # Creating Internet Gateway
  vpc_id = aws_vpc.main.id              # vpc_id will be generated after we create VPC
  tags = {
    "Name" = "${var.project_name}-IGW-${terraform.workspace}"
  }
}

resource "aws_eip" "ElasticIP" {
  public_ipv4_pool = "amazon"
  vpc              = true
  depends_on = [
    aws_internet_gateway.IGW
  ]

}
# Creating the NAT Gateway using subnet_id and allocation_id
resource "aws_nat_gateway" "NATgw" {
  allocation_id = aws_eip.ElasticIP.id
  subnet_id     = aws_subnet.public_subnet1.id
  tags = {
    "Name" = "${var.project_name}-NATgw-${terraform.workspace}"
  }
}

#creating Security group for VPC

resource "aws_security_group" "VPC_Security_group" {
  vpc_id      = aws_vpc.main.id
  description = "Security group with no restrictions"
  name        = "DefaultSecurityGroup"

  ingress = []
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      self             = false
      description      = ""
      ipv6_cidr_blocks = []
      security_groups  = []
      prefix_list_ids  = []
    },
  ]
}

resource "aws_security_group" "SQS" {
  name   = var.aws_security_group_SQS
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.private_subnet1]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.private_subnet1]
  }

  tags = {
    "Name" = "${var.project_name}-SQS-security_group-${terraform.workspace}"
  }
}

#VPC Endpoints
resource "aws_vpc_endpoint" "sqs" {
  service_name        = "com.amazonaws.ca-central-1.sqs"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.SQS.id]
  subnet_ids          = [aws_subnet.private1.id]
  vpc_endpoint_type   = "Interface"
  vpc_id              = aws_vpc.main.id
  tags = {
    "Name" = "${var.project_name}-sqs-vpc-endpoint"
  }
}
#  resource "aws_vpc_endpoint_route_table_association" "SQS_RT" {
#    route_table_id = aws_route_table.Fxlink_Private1_RT.id
#    vpc_endpoint_id = aws_vpc_endpoint.sqs.id
#  }

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.ca-central-1.dynamodb"
  #todo- Security group
  tags = {
    "Name" = "${var.project_name}-dynamodb-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint_route_table_association" "DynodB_RT" {
  route_table_id  = aws_route_table.Fxlink_Private1_RT.id
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.ca-central-1.s3"
  #todo- Security group
  tags = {
    "Name" = "${var.project_name}-s3-vpc-endpoint"
  }
}
resource "aws_vpc_endpoint_route_table_association" "S3_RT" {
  route_table_id  = aws_route_table.Fxlink_Private1_RT.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}