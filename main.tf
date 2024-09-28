# Description:  AWS infrastructure with Terraform

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9"
}

# TODO: Designate a cloud provider, region, and credentials

provider "aws" {
  region  = "us-east-1"
  access_key = "AKIAYGWUTNFMMA3ZFFRF"
  secret_key = "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"
}


# TODO: provision 4 AWS t2.micro EC2 instances named Udacity T2

resource "aws_instance" "Udacity-T2" {
    count = "4"
    ami = "ami-051f8a213df8bc089"
    instance_type = "t2.micro"
    tags = {
        Name = "Udacity T2"
    }
}

# TODO: provision 2 m4.large EC2 instances named Udacity M4

resource "aws_instance" "Udacity-M4" {
    count = "2"
    ami = "ami-051f8a213df8bc089"
    instance_type = "m4.large"
    tags = {
        Name = "Udacity M4"
    }
}
