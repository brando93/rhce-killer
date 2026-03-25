terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
    tls = { source = "hashicorp/tls", version = "~> 4.0" }
    local = { source = "hashicorp/local", version = "~> 2.0" }
  }
}

provider "aws" { region = var.aws_region }

# ── SSH Key Pair ──────────────────────────────────────────────
resource "tls_private_key" "rhce" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "rhce" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.rhce.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.rhce.private_key_pem
  filename        = "${path.module}/../${var.project_name}.pem"
  file_permission = "0600"
}

# ── VPC ───────────────────────────────────────────────────────
resource "aws_vpc" "rhce" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "${var.project_name}-vpc" }
}

resource "aws_internet_gateway" "rhce" {
  vpc_id = aws_vpc.rhce.id
  tags   = { Name = "${var.project_name}-igw" }
}

resource "aws_subnet" "rhce" {
  vpc_id                  = aws_vpc.rhce.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false
  tags                    = { Name = "${var.project_name}-subnet" }
}

resource "aws_route_table" "rhce" {
  vpc_id = aws_vpc.rhce.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.rhce.id
  }
  tags = { Name = "${var.project_name}-rt" }
}

resource "aws_route_table_association" "rhce" {
  subnet_id      = aws_subnet.rhce.id
  route_table_id = aws_route_table.rhce.id
}

# ── Security Groups ───────────────────────────────────────────
resource "aws_security_group" "control" {
  name   = "${var.project_name}-control-sg"
  vpc_id = aws_vpc.rhce.id

  ingress {
    description = "SSH from your IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-control-sg" }
}

resource "aws_security_group" "nodes" {
  name   = "${var.project_name}-nodes-sg"
  vpc_id = aws_vpc.rhce.id

  ingress {
    description     = "All traffic from control node"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.control.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-nodes-sg" }
}

# ── AMI: Rocky Linux 9 ────────────────────────────────────────
data "aws_ami" "rocky9" {
  most_recent = true
  owners      = ["679593333241"]

  filter {
    name   = "name"
    values = ["Rocky-9-EC2-Base-9.*-x86_64*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ── EC2 Instances ─────────────────────────────────────────────
resource "aws_instance" "control" {
  ami                         = data.aws_ami.rocky9.id
  instance_type               = var.control_instance_type
  subnet_id                   = aws_subnet.rhce.id
  vpc_security_group_ids      = [aws_security_group.control.id]
  key_name                    = aws_key_pair.rhce.key_name
  associate_public_ip_address = true
  private_ip                  = "10.0.1.10"

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  # templatefile() injects node IPs and the private key into the script
  user_data = templatefile("${path.module}/user_data/control.sh", {
    node1_ip    = "10.0.1.11"
    node2_ip    = "10.0.1.12"
    private_key = tls_private_key.rhce.private_key_pem
  })

  tags = { Name = "control.example.com", Role = "control" }
}

resource "aws_instance" "node1" {
  ami                         = data.aws_ami.rocky9.id
  instance_type               = var.node_instance_type
  subnet_id                   = aws_subnet.rhce.id
  vpc_security_group_ids      = [aws_security_group.nodes.id]
  key_name                    = aws_key_pair.rhce.key_name
  associate_public_ip_address = false
  private_ip                  = "10.0.1.11"

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  user_data = file("${path.module}/user_data/node.sh")
  tags      = { Name = "node1.example.com", Role = "node" }
}

resource "aws_instance" "node2" {
  ami                         = data.aws_ami.rocky9.id
  instance_type               = var.node_instance_type
  subnet_id                   = aws_subnet.rhce.id
  vpc_security_group_ids      = [aws_security_group.nodes.id]
  key_name                    = aws_key_pair.rhce.key_name
  associate_public_ip_address = false
  private_ip                  = "10.0.1.12"

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  user_data = file("${path.module}/user_data/node.sh")
  tags      = { Name = "node2.example.com", Role = "node" }
}
