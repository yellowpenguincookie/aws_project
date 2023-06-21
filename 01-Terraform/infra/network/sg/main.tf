# 디폴트 보안그룹 
# resource "aws_default_security_group" "aws04_default_sg" {
#    vpc_id = data.terraform_remote_state.aws04_vpc.outputs.vpc_id


#   ingress {
#      protocol    = "tcp"
#        from_port   = 0
#        to_port     = 65535
#        cidr_blocks = [data.terraform_remote_state.aws04_vpc.outputs.vpc_cidr]
#    }

#    egress {
#        protocol    = "-1"
#        from_port   = 0
#        to_port     = 0
#        cidr_blocks = ["0.0.0.0/0"]
#    }

#    tags = {
#        Name = "aws04_default_sg"
#        Description = "default security group"
#    }
# }


#SSH Security group
resource "aws_security_group" "aws04_ssh_sg" {
    name   = "aws04_ssh_sg"
    description = "security group for ssh server"
    vpc_id = data.terraform_remote_state.aws04_vpc.outputs.vpc_id


    ingress {
        description = "For SSH port"
        protocol    = "tcp"
        from_port   = 22
        to_port     = 22
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "aws04_ssh_sg"
        Description = "SSH security group"
    }
}


#WEB Security group
resource "aws_security_group" "aws04_web_sg" {
    name        = "aws04_web_sg"
    description = "security group for WEB server"
    vpc_id      = data.terraform_remote_state.aws04_vpc.outputs.vpc_id


    ingress {
        description = "For WEB port"
        protocol    = "tcp"
        from_port   = 80
        to_port     = 80
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "aws04_web_sg"
        Description = "WEB security group"
    }
}



