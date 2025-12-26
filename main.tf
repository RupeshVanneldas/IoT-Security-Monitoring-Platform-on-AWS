terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS provider
provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "prod_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Project-VPC"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.prod_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Project-Public-Subnet-1"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.prod_vpc.id

  tags = {
    Name = "Project-Internet-Gateway"
  }
}

# Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.prod_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "Project-Public-Route-Table"
  }
}

resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

# Security Group
resource "aws_security_group" "web_sg" {
  name        = "Project-Web-SG"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.prod_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1883
    to_port     = 1883
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Project-SG"
  }
}

# Latest Ubuntu 22.04 LTS (Jammy) AMD64 HVM EBS-GP2 AMI from Canonical
data "aws_ssm_parameter" "ubuntu_2204_ami" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

# ssh-keygen -t rsa -b 4096 -C "project-key" -f ./project-key

resource "aws_key_pair" "project_key" {
  key_name   = "project-key"
  public_key = file("${path.module}/project-key.pub")
}

# EC2 Instance
resource "aws_instance" "web_server" {
  ami                         = data.aws_ssm_parameter.ubuntu_2204_ami.value
  instance_type               = "t3.large" # 2 vCPU, 8 GB RAM
  subnet_id                   = aws_subnet.public_subnet_1.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.project_key.key_name

  root_block_device {
    volume_size           = 80  # 80 GB
    volume_type           = "gp3" # SSD (gp3)
    delete_on_termination = true
    encrypted             = true
  }
  tags = {
    Name = "TempSensor-Web-Server"
  }
}

resource "aws_eip" "web_eip" {
  domain = "vpc"
  tags   = { Name = "Project-EIP" }
}

resource "aws_eip_association" "web_eip_association" {
  instance_id   = aws_instance.web_server.id
  allocation_id = aws_eip.web_eip.id
}

resource "aws_s3_bucket" "vpc_flow_logs" {
  bucket_prefix = "project-vpc-flow-logs-"
  force_destroy = true

  tags = {
    Name = "Project-VPC-Flow-Logs"
  }
}

data "aws_iam_policy_document" "vpc_flow_logs_policy" {
  statement {
    sid = "AWSVPCFlowLogsWrite"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.vpc_flow_logs.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "vpc_flow_logs_policy" {
  bucket = aws_s3_bucket.vpc_flow_logs.id
  policy = data.aws_iam_policy_document.vpc_flow_logs_policy.json
}

resource "aws_flow_log" "project_vpc_flow_log" {
  log_destination      = aws_s3_bucket.vpc_flow_logs.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.prod_vpc.id

  tags = {
    Name = "Project-VPC-Flow-Logs"
  }
}

resource "aws_s3_bucket" "athena_results" {
  bucket_prefix = "project-athena-results-"
  force_destroy = true

  tags = {
    Name = "Project-Athena-Results"
  }
}

resource "aws_athena_database" "project_flow_logs_db" {
  name   = "project_vpc_flow_logs_db"
  bucket = aws_s3_bucket.athena_results.bucket
}

resource "aws_athena_workgroup" "project_analysis" {
  name          = "project_analysis"
  force_destroy = true

  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results.bucket}/results/"
    }
  }
}
