resource "aws_internet_gateway" "custom-ig" {
    vpc_id = aws_vpc.custom-vpc.id 

    tags = {
        "Name" = "custom-ig"
    }
}