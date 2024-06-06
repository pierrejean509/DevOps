resource "aws_route_table_association" "custom-rt-internet-association" {
    subnet_id = aws_subnet.public-subnet.id
    route_table_id = aws_route_table.custom-rt-internet.id 
}