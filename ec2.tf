// Create Security Group and Allow 22 & 80 Port

variable "sg_ports" {
  type        = list(number)
  description = "list of ingress ports"
  default     = [22, 80]
}

resource "aws_security_group" "sg" {
  name        = "dynamic-sg-1"
  description = "Dynamic Ingress Rules"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.sg_ports
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

// Create EC2 Instance & Configure Nginx Web Server

resource "aws_instance" "myec2-1" {
  ami                    = "ami-099b3d23e336c2e83"
  instance_type          = "t2.micro"
  key_name               = "terraform-key"
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id              = aws_subnet.private_subnet.id

  # connection {
  #   type        = "ssh"
  #   user        = "ec2-user"
  #   private_key = file("./terraform-key.pem")
  #   host        = self.public_ip
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo yum install -y nginx",
  #     "sudo systemctl start nginx"
  #   ]
  # }

  #user_data = <<-EOF
              #!/bin/bash
                #"sudo yum install -y nginx"
                #"sudo systemctl start nginx"
              #EOF

   tags = {
    Name = "Nginx-Instance"
  }
}






