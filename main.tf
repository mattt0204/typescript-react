data "aws_ami" "amazon_linux_2" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

terraform {

  backend "remote" {
    organization = "terraform-aws101"
    workspaces {
      name = "typescript-react"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "ap-northeast-2"
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"

  tags = {
    Name = var.instance_name
  }
}


