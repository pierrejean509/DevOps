resource  "aws_instance" "ec2-control1" {
    ami = "ami-0e001c9271cf7f3b9" # ubuntu image 22.04
    instance_type = "t2.medium"
    subnet_id = aws_subnet.public-subnet.id
    vpc_security_group_ids = [aws_security_group.custom-sg.id]
    key_name = "cluster-k8s"

    tags = {
        "Name" = "ec2-control1"
    }
}

resource  "aws_instance" "ec2-control2" {
    ami = "ami-0e001c9271cf7f3b9" # ubuntu image 22.04
    instance_type = "t2.medium"
    subnet_id = aws_subnet.public-subnet.id
    vpc_security_group_ids = [aws_security_group.custom-sg.id]
    key_name = "cluster-k8s"

    tags = {
        "Name" = "ec2-control2"
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

resource  "aws_instance" "ec2-worker3" {
    ami = "ami-0e001c9271cf7f3b9" # ubuntu image 22.04
    instance_type = "t2.medium"
    subnet_id = aws_subnet.public-subnet.id
    vpc_security_group_ids = [aws_security_group.custom-sg.id]
    key_name = "cluster-k8s"

    tags = {
        "Name" = "ec2-worker3"
    }
}






