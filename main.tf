terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    random = {
      source = "hashicorp/random"
    }
  }

  backend "remote" {
    organization = "BillyBui"

    workspaces {
      name = "parcel"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

provider "random" {}

resource "random_pet" "sg" {}

resource "aws_key_pair" "deployer" {
  key_name   = "ubuntu"
  public_key = file("key.pub")
}

resource "aws_instance" "web" {
  key_name               = aws_key_pair.deployer.key_name
  ami                    = "ami-06fb5332e8e3e577a"
  instance_type          = "t2.small"
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  

}

resource "aws_security_group" "web-sg" {
  name = "${random_pet.sg.id}-sg"
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "web-address" {
  value = "${aws_instance.web.public_dns}:8000"
}