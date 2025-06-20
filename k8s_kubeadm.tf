# Terraform: 3-node K8s cluster with Calico + BGP in AWS (single AZ)

provider "aws" {
  region = "us-east-1" # North Virginia
}

# 1. VPC
resource "aws_vpc" "k8s_vpc" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "k8s-vpc"
  }
}

# 2. Subnet
resource "aws_subnet" "k8s_subnet" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = "172.16.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "k8s-subnet"
  }
}

# 3. Internet Gateway
resource "aws_internet_gateway" "k8s_igw" {
  vpc_id = aws_vpc.k8s_vpc.id
  tags = {
    Name = "k8s-igw"
  }
}

# 4. Route Table
resource "aws_route_table" "k8s_route_table" {
  vpc_id = aws_vpc.k8s_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s_igw.id
  }
  tags = {
    Name = "k8s-route-table"
  }
}

resource "aws_route_table_association" "k8s_rta" {
  subnet_id      = aws_subnet.k8s_subnet.id
  route_table_id = aws_route_table.k8s_route_table.id
}

# 5. Security Group
resource "aws_security_group" "k8s_sg" {
  name        = "k8s-sg"
  description = "K8s BGP + Calico"
  vpc_id      = aws_vpc.k8s_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "udp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-sg"
  }
}

# 6. Key Pair
resource "aws_key_pair" "k8s_key" {
  key_name   = "k8s_mykey"
  public_key = file("~/.ssh/id_rsa.pub")
}

# 7. EC2 Instances (1 Master, 2 Workers)
resource "aws_instance" "k8s_nodes" {
  count                       = 3
  ami                         = "ami-0a7d80731ae1b2435" # Ubuntu 22.04 LTS us-east-1
  instance_type               = "t2.medium"
  subnet_id                   = aws_subnet.k8s_subnet.id
  key_name                    = aws_key_pair.k8s_key.key_name
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true

  private_ip = element([
    "172.16.1.10",
    "172.16.1.11",
    "172.16.1.12"
  ], count.index)

  tags = {
    Name = element(["k8s-master", "k8s-worker-1", "k8s-worker-2"], count.index)
  }

  # user_data = file("bootstrap.sh")
}
