provider "aws" {
    region = "us-east-1"
}

resource "aws_vpc" "custom-vpc" {
    cidr_block = "10.0.0.0/16" #IP ranges available inside vpc
    instance_tenancy = "default"

    tags = {
        "Name" = "custom-vpc"
    }
}