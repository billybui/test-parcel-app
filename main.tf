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

resource "aws_instance" "web" {
  ami                    = "ami-06fb5332e8e3e577a"
  instance_type          = "t2.small"
  vpc_security_group_ids = [aws_security_group.web-sg.id]

  user_data = <<-EOF
              #!/bin/bash
              git clone https://github.com/billybui/test-parcel-app.git && chmod +x test-parcel-app/startup.sh && test-parcel-app/startup.sh &
              EOF
}

resource "aws_security_group" "web-sg" {
  name = "${random_pet.sg.id}-sg"
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "web-address" {
  value = "${aws_instance.web.public_dns}:8080"
}