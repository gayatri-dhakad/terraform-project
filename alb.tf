// Create Security Group for load balancer and Allow 80 & 443 Port

variable "sg_port" {
  type        = list(number)
  description = "list of ingress ports"
  default     = [80, 443]
}

resource "aws_security_group" "lb-sg" {
  name        = "lb-sg"
  description = "Dynamic Ingress Rules"
  vpc_id      = aws_vpc.main.id
  
  dynamic "ingress" {
    for_each = var.sg_port
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    description = "Outbound Allowed"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//Create Target Group for Application Load Balancer

resource "aws_lb_target_group" "tg" {
  name     = "lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

# //Create Application Load Balancer for EC2 instance

resource "aws_lb" "alb" {
 internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-sg.id]
  subnets            = [aws_subnet.public_subnet.id,aws_subnet.public_subnet1.id]

  

  tags = {
    name = "ALB"
  }
}

//Create Listener for ALB

resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

//attachment target group to instance

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.myec2-1.id
  port             = 80
}
