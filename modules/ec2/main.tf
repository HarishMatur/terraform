## This block of code it to create the ec2 instances with security group attached to it.

resource "aws_instance" "test1" {
    instance_type = "var.instance_type"
    region = "var.region"
    ami = "var.ami"
    vpc_security_group_ids = [aws_security_group.testing_sg.id]
    associate_public_ip_address = true
    key_name = "var.key_name"
    
    tags = {
        Name = "Testing-instance"
    }
}

resource "aws_security_group" "testing_sg" {
    name = "test1-sg"
    description = "security group for test1 instance"
    
    ingress {
        from_port = 22
        to_port = 22
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "test1-sg"
    }
}