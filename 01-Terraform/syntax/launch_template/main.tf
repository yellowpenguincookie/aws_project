provider "aws" {
  region = "ap-northeast-2"
}
#AWS 인스턴스 생성 
#AWS launch configuration create 
resource "aws_launch_template" "example" {
	name						= "aws04-example"
	image_id        = "ami-0c6e5afdd23291f73"
  instance_type   = "t2.micro"
  vpc_security_group_ids 	= [aws_security_group.instance.id]
	key_name 				= "aws04-key"
  
	user_data = "${base64encode(data.template_file.web_output.rendered)}"
	
	lifecycle {
    create_before_destroy = true
  }
}

#오토스케일링 그룹 
#AWS auto scaling group create 
resource "aws_autoscaling_group" "example" {
	availability_zones	= ["ap-northeast-2a", "ap-northeast-2c"]
	
	name 						 = "aws04-terraform-asg-example"
	desired_capacity = 1
  min_size				 = 1
  max_size				 = 2

	launch_template {
		id						= aws_launch_template.example.id
		version 			= "$Latest"
	}


  tag {
    key                 = "Name"
    value               = "aws04-terraform-asg-example"
    propagate_at_launch = true
  }
}

#보안그룹 생성
resource "aws_security_group" "instance" {
  name				= "aws04-terraform-example-instance"
	description = "security group for launch_template"


  ingress {
	
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Default VPC 정보 가져 오기
data "aws_vpc" "default"  {
	filter {
		name = "tag:Name"
		values = ["604-vpc"]
	}
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "template_file" "web_output" {
	template = file("${path.module}/web.sh")
	vars = {
		server_port = "${var.server_port}"
	}
}


variable "server_port" {
  description = "The port will use for HTTP requests"
  type        = number
  default     = 8080
}

