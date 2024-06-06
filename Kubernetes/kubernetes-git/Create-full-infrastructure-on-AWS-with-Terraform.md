IaaC - Create full infrastructure on AWS with Terraform

First - Download Terraform

Debian/Ubuntu Installation:
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

Next - Install AWSCLI
sudo apt install awscli

OR

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

Now open vscode to build our infrastructure:

- 1 VPC
- 1 subnet
- 1 sercurity group
- 3 ec2 instaces (1 Master and  2 workers)
- 1 networl ACL
- A route table
- An internet gateway

- Create the VPC:

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

After creating the VPC open the terminal and type "terraform init" to initialize the terraform file inside of the application
to be able to create these resources.

After type "terraform plan" to have an overview about what ew gonna create.

N.B: If "terraform plan" give a credentials error, you have to configure the AWS ACCESS KEY ID, the AWS SECRET ACCESS KEY ID
and the AWS DEFAULT REGION by typing.
export AWS_ACCESS_KEY_ID=AKIAYZ2Z4L4HONCSVBPY
export AWS_SECRET_ACCESS_KEY=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
export AWS_DEFAULT_REGION="us-east-1"

Type "terraform plan" again
and "terraform apply"

- Create a subnet:

resource "aws_subnet" "public-subnet" {
    vpc_id = aws_vpc.custom-vpc.id 
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true 

    tags = {
        "name" = "10.0.2.0 - us-east-1a"
    }
}

Type "terraform plan" again
and "terraform apply"

- Create a Security Group:

resource "aws_security_group" "custom-sg" {
    vpc_id = aws_vpc.custom-vpc.id 

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 6443
        to_port = 6443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 2379
        to_port = 2379
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    

    tags = {
        "Name" = "custom-sg"
        "Description" = "custom-sg"
    }

}

Type "terraform plan" again
and "terraform apply"


- Create an Internet Gateway:

resource "aws_internet_gateway" "custom-ig" {
    vpc_id = aws_vpc.custom-vpc.id 

    tags = {
        "Name" = "custom-ig"
    }
}


- Create my custom Route Table:

resource "aws_route_table" "custom-rt-internet" {
    vpc_id = aws_vpc.custom-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.custom-ig.id 
    } 

    tags = {
        "Name" = "custom-rt-internet"
    }

 }
 

- Create an associated route table:

resource "aws_route_table_association" "custom-rt-internet-association" {
    subnet_id = aws_subnet.public-subnet.id
    route_table_id = aws_route_table.custom-rt-internet.id 
}


Create our 3 ec2 instances:

resource  "aws_instance" "ec2-control" {
    ami = "ami-0e001c9271cf7f3b9" # ubuntu image 22.04
    instance_type = "t2.medium"
    subnet_id = aws_subnet.public-subnet.id
    vpc_security_group_ids = [aws_security_group.custom-sg.id]
    key_name = "cluster-k8s"

    tags = {
        "Name" = "ec2-control"
    }
}

resource  "aws_instance" "ec2-worker1" {
    ami = "ami-0e001c9271cf7f3b9" # ubuntu image 22.04
    instance_type = "t2.medium"
    subnet_id = aws_subnet.public-subnet.id
    vpc_security_group_ids = [aws_security_group.custom-sg.id]
    key_name = "cluster-k8s"

    tags = {
        "Name" = "ec2-worker1"
    }
}

resource  "aws_instance" "ec2-worker2" {
    ami = "ami-0e001c9271cf7f3b9" # ubuntu image 22.04
    instance_type = "t2.medium"
    subnet_id = aws_subnet.public-subnet.id
    vpc_security_group_ids = [aws_security_group.custom-sg.id]
    key_name = "cluster-k8s"

    tags = {
        "Name" = "ec2-worker2"
    }
}








