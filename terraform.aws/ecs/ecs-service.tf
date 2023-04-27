resource "aws_ecs_service" "sac_ecs_service" {
  name            = "sac-testing-ecs-service"
  cluster         = aws_ecs_cluster.sac_ecs_cluster.arn
  task_definition = aws_ecs_task_definition.sac_ecs_task_definition.arn
  launch_type     = "EC2"
}

resource "aws_subnet" "sac_ecs_subnet" {
  vpc_id     = aws_vpc.sac_ecs_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main"
  }
}

resource "aws_vpc" "sac_ecs_vpc" {
  cidr_block = "10.0.0.0/16" 
}

resource "aws_security_group" "sac_ecs_security_group" {
  name                   = "sac-ecs-sec-group"
  description            = "Allow TLS inbound traffic"
  vpc_id                 = aws_vpc.sac_ecs_vpc.id
  revoke_rules_on_delete = false

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  # oak9: Explicitly define destination IP addresses for egress rules
  }
}