terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

/*resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}*/

resource "aws_security_group" "allow_http_traffic" {
  name        = "allow_http_traffic"
  description = "Allow HTTP inbound traffic"
  //vpc_id      = aws_vpc.main.id

  ingress {
    description      = "http from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks	= ["0.0.0.0/0"]
    //cidr_blocks      = [aws_vpc.main.cidr_block]
    //ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]

  }

  ingress {
    description = "ssh access"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_instance" "app_server" {
  ami           = "ami-0b5eea76982371e91"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.allow_http_traffic.id}"]
  key_name = "terraform"

  user_data = <<-EOF
              #!/bin/bash
              sudo amazon-linux-extras install docker -y
              sudo service docker start
              sudo usermod -a -G docker ec2-user
              sudo chkconfig docker on
              sudo yum install -y git
              sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose
              git clone https://github.com/yelhadad/terraform-taskl.git
              cd terraform-taskl
              docker-compose up -d
              EOF
  tags = {
    Name = "terraform-task"
  }
}
