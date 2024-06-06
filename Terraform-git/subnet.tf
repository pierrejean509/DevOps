resource "aws_subnet" "public-subnet" {
    vpc_id = aws_vpc.custom-vpc.id 
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true 

    tags = {
        "name" = "10.0.2.0 - us-east-1a"
    }
}