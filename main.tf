terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "cdunlap"

    workspaces {
      name = "aws-sentinel-ec2-geofence-tagging-sizing"
    }
  }
}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  #don't change this from us-west-2 :)
  region = "us-west-2"
}

variable "aws_access_key" {
  description = "access key"
}

variable "aws_secret_key" {
  description = "secret key"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "demo" {
  ami           = "${data.aws_ami.ubuntu.id}"
  #do not change this from t2.micro, unless you want to trigger sentinel
 #instance_type = "t2.micro"
 instance_type = "t2.2xlarge"
  key_name = "cdunlap-demo"
  
  tags = {
    Name = "cdunlap simple ec2 demo"
    #uncomment this for working, comment out for sentinel policy trigger
 Owner = "cdunlap@hashicorp.com"
    TTL = "24h"
      }   
}

output "private_ip" {
  description = "Private IP of instance"
  value       = "${join("", aws_instance.demo.*.private_ip)}"
}

output "public_ip" {
  description = "Public IP of instance (or EIP)"
  value       = "${join("", aws_instance.demo.*.public_ip)}"
}
