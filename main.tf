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
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCeLqIrGeHEHJ+i/qxTZoPfkZl4GbA31trjhupoRg23lbz6cjvE3R33dbpsTHYk90XGUmzAx07Gz67FghdP+YxCgCjZUAc6sVLmDWopeT3smfpHQe03j4PmzkwTyQXSdjtTpCgS7HUmjFr9tXYmMmyF4upWKomhKcSwh5xjYY4Kg/D6RZaGswL/l7cPQhQXeOdi1Rnk0GVxWz9pjq/mle0xjUC0gt0ML2byaxgsGjfe/Pg1IQJkZxq+Y6EQvSB/j1ZFXFNUWflD/g29SoeeVFuG0z+LZh8UHegd5PV07o0kF/S5Y5qjn5b9ONaveEYxA5d/nLVZXxoj+9Pzsh6fEoAn imported-openssh-key"
}

resource "aws_instance" "web" {
  ami                    = "ami-06fb5332e8e3e577a"
  instance_type          = "t2.small"
  key_name = "${aws_key_pair.deployer.key_name}"
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
  value = "${aws_instance.web.public_dns}:8000"
}