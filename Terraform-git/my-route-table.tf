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