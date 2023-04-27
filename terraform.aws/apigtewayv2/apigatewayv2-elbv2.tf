resource "aws_lb" "elbv2_sac" {
  name               = "elbv2-sac"
  load_balancer_type = "application"
  drop_invalid_header_fields = true
  desync_mitigation_mode = "monitor"
  internal = false
  subnets = [aws_subnet.apigwv2_subnet.id, aws_subnet.apigwv2_subnet_2.id]  

}

resource "aws_lb_listener" "elbv2_listener" {
  load_balancer_arn = aws_lb.elbv2_sac.arn
  port = 99

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.elbv2_target_group.arn
  }

  depends_on = [
    aws_lb_target_group.elbv2_target_group
  ]
}

resource "aws_lb_target_group" "elbv2_target_group" {
  name     = "elbv2-target-group-sac"
  target_type = "instance"
  vpc_id   = aws_vpc.apigwv2_vpc.id
  port     = 80
  protocol = "HTTP" # oak9: protocol should be set to any of ['https', 'tls']

  health_check {
    enabled = true
    protocol = "HTTP"
  }
}

resource "aws_lb_target_group_attachment" "elbv2_target_group_attachment" {
  target_group_arn = aws_lb_target_group.elbv2_target_group.arn
  target_id        = aws_instance.aws_ec2_instance_sac_default.id
}

resource "aws_instance" "aws_ec2_instance_sac_default" {
  ami = data.aws_ami.ubuntu.id
  subnet_id = aws_subnet.apigwv2_subnet.id
  iam_instance_profile = "ec2-instance-profile-default"

  launch_template {
    id = aws_launch_template.aws_ec2_launch_template_sac_default.id
  }

  associate_public_ip_address = false
  availability_zone = "us-east-2c"
  monitoring = true
  vpc_security_group_ids = [aws_security_group.apigwv2_security_group.id]

  tags = {
    key = "value"
  }

  ebs_block_device {
    delete_on_termination = false
    device_name = "/dev/sdf"
    encrypted = true

    kms_key_id = aws_kms_key.ec2_instance_kms_key_default.id
    volume_size = 5

    tags = {
      "key" = "value"
    }
  }
}

resource "aws_kms_key" "ec2_instance_kms_key_default" {
  description             = "Instance-key"
  deletion_window_in_days = 10
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_iam_role" "ec2_instance_role_default" {
  name = "ec2-instance-role-default"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_launch_template" "aws_ec2_launch_template_sac_default" {
  name = "ec2-instance-launch-template-sac-default"
  default_version = 1
  disable_api_stop        = false
  disable_api_termination = false
  ebs_optimized = true
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t2.micro"

  tags = {
    "key" = "value"
  }

  metadata_options {
  http_endpoint               = "enabled"
  http_tokens                 = "required"
  http_put_response_hop_limit = 1
  instance_metadata_tags      = "enabled"
  }
}