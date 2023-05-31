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
	availability_zones	= ["ap-northeast-2a", "ap-northeast-2c"]

	name 							= "aws04-terraform-asg-example"
	desired_capacity 	= 1
  min_size				 	= 1
  max_size				 	= 2

	target_group_arns = [aws_lb_target_group.asg.arn]
	health_check_type	= "ELB"

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

#로드밸런서 생성 
resource "aws_lb" "example" {
	name							= "aws04-terraform-asg-example"
	load_balancer_type= "application"
#로드밸런스 생성되는 vpc의 서브넷 
	subnets 				  = data.aws_subnets.default.ids 
#로드밸런스에 사용할 보안 그룹들 
	security_groups		= [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
	load_balancer_arn = aws_lb.example.arn
	port 							= 80
	protocol					= "HTTP"

	default_action {
		type						= "fixed-response"
		fixed_response {
			content_type	= "text/plain"
			message_body	= "404: page not found"
			status_code 	= 404
		}
	}
}

#로드밸런서 리스너 룰 구성
resource "aws_lb_listener_rule" "asg" {
	listener_arn	= aws_lb_listener.http.arn
	priority			= 100

	condition {
		path_pattern {
			values = ["*"]
		}
	}

	action {
		type 			= "forward"
			target_group_arn = aws_lb_target_group.asg.arn
		}
}

#로드밸런서 대상그룹
resource "aws_lb_target_group" "asg" {
	name	= "aws04-terraform-asg-example"
	port	= var.server_port
	protocol	= "HTTP"
	vpc_id		= data.aws_vpc.default.id

	health_check {
		path			= "/"
		protocol	= "HTTP"
		matcher		= "200"
		interval 	= 15
		timeout		= 3
		healthy_threshold		= 2
		unhealthy_threshold	= 2
	}	
}



#보안그룹 생성- instance
resource "aws_security_group" "instance" {
	name = "aws04-terraform-example-instance"
	description = "security group for instance"

	ingress {
		from_port 	= var.server_port
		to_port			= var.server_port
		protocol		= "tcp"
		cidr_blocks	= ["0.0.0.0/0"]
	}
}

#보안그룹 - ALB 
resource "aws_security_group" "alb" {
	name	= "aws04-terraform-example-alb"
	description = "security group for alb"

#인바운드 HTTP 트래픽 허용 
  ingress {
	  from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  	cidr_blocks = ["0.0.0.0/0"]
	}

#모든 아웃바운드 트래픽 허용 
	egress {
		from_port		= 0
		to_port 		= 0
		protocol		= "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}


#Default VPC 정보 가져 오기
data "aws_vpc" "default"  {
	default = true 
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

