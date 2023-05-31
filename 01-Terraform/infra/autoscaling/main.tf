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
		# Required when using a launch configuration with an auto scaling group..	
	lifecycle {
    create_before_destroy = true
  }
}

#오토스케일링 그룹 
#AWS auto scaling group create 
resource "aws_autoscaling_group" "example" {
#가용영역 지정 
#availability_zones	= ["ap-northeast-2a", "ap-northeast-2c"]
#subnet 지정
	vpc_zone_identifier = [var.subnet_public_1, var.subnet_public_2]

	name 							= "aws04-terraform-asg-example"
	desired_capacity 	= 1
  min_size				 	= 1
  max_size				 	= 2

	launch_template {
		id							= aws_launch_template.example.id
		version 				= "$Latest"
	}


  tag {
    key                 = "Name"
    value               = "aws04-terraform-asg-example"
    propagate_at_launch = true
  }
}

#보안그룹 생성- instance
resource "aws_security_group" "instance" {
	name = "aws04-terraform-example-instance"
	vpc_id = var.vpc_id 
#data로는 넣을수 없음. variable(변수var) 혹은 vpc ID 를 붙여넣어야 함. 

	description = "security group for instance"

	ingress {
		from_port 	= var.server_port
		to_port			= var.server_port
		protocol		= "tcp"
		cidr_blocks	= ["0.0.0.0/0"]
	}
}

variable "vpc_id" {
	default = "<vpc-id>"
}

variable "subnet_public_1" {
	default = "<subnet-id>"
}

variable "subnet_public_2" {
	default = "<subnet-id>"
}


#지우면 안됨 
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

