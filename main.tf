# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

#1. Create a vpc
resource "aws_vpc" "mini_project-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "mini project vpc"
  }
}

#2. Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.mini_project-vpc.id

  tags = {
    Name = "mini project internet gateway"
  }
}

#3. Create custom public route table
resource "aws_route_table" "mini_project" {
  vpc_id = aws_vpc.mini_project-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "mini project mini project"
  }
}

#4. create a subnet-1
resource "aws_subnet" "mini_project-subnet1" {
  vpc_id                  = aws_vpc.mini_project-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "mini project subnet-1"
  }
}

#4b. create a subnet-2
resource "aws_subnet" "mini_project-subnet2" {
  vpc_id                  = aws_vpc.mini_project-vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"

  tags = {
    Name = "mini project subnet-2"
  }
}

#5. Associate subnet1 with route table
resource "aws_route_table_association" "subnet1_associate" {
  subnet_id      = aws_subnet.mini_project-subnet1.id
  route_table_id = aws_route_table.mini_project.id
}

#5b. Associate subnet2 with route table
resource "aws_route_table_association" "subnet2-associate" {
  subnet_id      = aws_subnet.mini_project-subnet2.id
  route_table_id = aws_route_table.mini_project.id
}

#6. Network ACL
resource "aws_network_acl" "mini_project_acl" {
  vpc_id     = aws_vpc.mini_project-vpc.id
  subnet_ids = [aws_subnet.mini_project-subnet1.id, aws_subnet.mini_project-subnet2.id]

  ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "mini_project_acl"
  }
}

#7. Create a security group that allow ports 80 and 443 for load balancer
resource "aws_security_group" "load_balancer_sg" {
  name        = "load_balancer-sg"
  description = "Allow web traffic on load balancer"
  vpc_id      = aws_vpc.mini_project-vpc.id

  ingress {
    description      = "http traffic"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "https traffic"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow web traffic on load balancer"
  }
}

#8. Create a security group that allow ports 22, 80, 443 on ec2
resource "aws_security_group" "ec2_sg" {
  name        = "allow_web_traffic_ec2_sg"
  description = "Allow web traffic for ec2"
  vpc_id      = aws_vpc.mini_project-vpc.id

  ingress {
    description      = "http traffic"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    security_groups  = [aws_security_group.load_balancer_sg.id]
  }
  ingress {
    description      = "https traffic"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    security_groups  = [aws_security_group.load_balancer_sg.id]
  }
  ingress {
    description      = "SSH traffic"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2 sg"
  }
}

#9. Create ubuntu server
resource "aws_instance" "web-server-instance1" {
  ami               = "ami-00874d747dde814fa"
  instance_type     = var.instance_type
  subnet_id         = aws_subnet.mini_project-subnet1.id
  security_groups   = [aws_security_group.ec2_sg.id]
  availability_zone = "us-east-1a"
  key_name          = var.key_name

  tags = {
    "Name" = "ubuntu web server1"
  }
}
resource "aws_instance" "web-server-instance2" {
  ami               = "ami-00874d747dde814fa"
  instance_type     = var.instance_type
  subnet_id         = aws_subnet.mini_project-subnet2.id
  security_groups   = [aws_security_group.ec2_sg.id]
  availability_zone = "us-east-1b"
  key_name          = var.key_name

  tags = {
    "Name" = "ubuntu web server2"
  }
}
resource "aws_instance" "web-server-instance3" {
  ami               = "ami-00874d747dde814fa"
  instance_type     = var.instance_type
  subnet_id         = aws_subnet.mini_project-subnet1.id
  security_groups   = [aws_security_group.ec2_sg.id]
  availability_zone = "us-east-1a"
  key_name          = var.key_name

  tags = {
    "Name" = "ubuntu web server3"
  }
}

#10. Output all the instances puplic Ip addresses
output "first_server_IP" {
  value       = aws_instance.web-server-instance1.public_ip
  description = "first instance puplic IP"
}
output "second_server_IP" {
  value       = aws_instance.web-server-instance2.public_ip
  description = "second instance puplic IP"
}
output "third_server_IP" {
  value       = aws_instance.web-server-instance3.public_ip
  description = "third instance puplic IP"
}

#11. Store my instance public IP in a local file
resource "local_file" "server_Ip_addresses" {
  filename = "/vagrant/terraform/miniProject/host-inventory"
  content  = <<EOT
${aws_instance.web-server-instance1.public_ip}
${aws_instance.web-server-instance2.public_ip}
${aws_instance.web-server-instance3.public_ip}
  EOT
}

#12. Create a load balancer
resource "aws_lb" "mini_project_lb" {
  name                       = "mini-project-lb-tf"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.load_balancer_sg.id]
  subnets                    = [aws_subnet.mini_project-subnet1.id, aws_subnet.mini_project-subnet2.id]
  enable_deletion_protection = false
  depends_on                 = [aws_instance.web-server-instance1, aws_instance.web-server-instance2, aws_instance.web-server-instance3]
}

#13 Create Target Group
resource "aws_lb_target_group" "mini_project_tg" {
  name        = "mini-project-target-group"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.mini_project-vpc.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

#14. Create a load balancer Listener
resource "aws_lb_listener" "mini_project_listener" {
  load_balancer_arn = aws_lb.mini_project_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mini_project_tg.arn
  }
}

#15. Create a load balancer Listener rule
resource "aws_lb_listener_rule" "mini_project_listener_rule" {
  listener_arn = aws_lb_listener.mini_project_listener.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mini_project_tg.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

#16. Attach the target group to the load balancer
resource "aws_lb_target_group_attachment" "mini_project_lb_tg_attachment" {
  target_group_arn = aws_lb_target_group.mini_project_tg.arn
  target_id        = aws_instance.web-server-instance1.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "mini_project_lb_tg_attachment2" {
  target_group_arn = aws_lb_target_group.mini_project_tg.arn
  target_id        = aws_instance.web-server-instance2.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "mini_project_lb_tg_attachment3" {
  target_group_arn = aws_lb_target_group.mini_project_tg.arn
  target_id        = aws_instance.web-server-instance3.id
  port             = 80
}
