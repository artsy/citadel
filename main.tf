provider "aws" {}

resource "aws_security_group" "citadel-test" {
    name        = "${var.stack_name}-test"
    description = "${var.stack_name} test"
    vpc_id      = "${var.vpc_id}"

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    tags {
        "Name" = "${var.stack_name} test"
    }
}

resource "aws_instance" "citadel-test" {
    ami                         = "ami-fce3c696"
    availability_zone           = "us-east-1b"
    ebs_optimized               = false
    instance_type               = "t2.micro"
    monitoring                  = false
    key_name                    = "${var.key_name}"
    subnet_id                   = "${var.subnet_id}"
    vpc_security_group_ids      = ["${aws_security_group.citadel-test.id}"]
    iam_instance_profile        = "${var.iam_instance_profile}"

    associate_public_ip_address = true
    source_dest_check           = true
    disable_api_termination     = false

    root_block_device {
        volume_type           = "gp2"
        volume_size           = 8
        delete_on_termination = true
    }

    tags {
        "Name" = "${var.stack_name} test"
    }
}
