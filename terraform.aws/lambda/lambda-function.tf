resource "aws_lambda_function" "insecure_lambda_SAC" {
  function_name = "insecure_lambda_function"   
  role = aws_iam_role.lambda_role.arn     
	filename   = "my-deployment-package.zip"  
  handler = "index.handler"
  runtime = "ruby2.6"
  reserved_concurrent_executions = 0
  layers = [aws_lambda_layer_version.lambda_layer.arn]
	
  tags = {
    Name = "foo function"
  }
}

resource "aws_sns_topic" "topic-sns" {
  name = "user-updates-topic"
}

resource "aws_security_group" "security-group-lambda" {
  vpc_id     = aws_vpc.main.id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    # oak9: Explicitly define destination IP addresses for egress rules
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_subnet" "test-subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_iam_role" "lambda_role" {
    name = "lambda_role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",

      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "sns:Publish",
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeInstances",
          "ec2:AttachNetworkInterface",
          "kinesis:GetRecords",
          "kinesis:GetShardIterator",
          "kinesis:DescribeStream",
          "kinesis:ListShards",
          "kinesis:ListStreams",
          "lambda:GetLayerVersion",
          "lambda:InvokeFunction",
          "lambda:AddLayerVersionPermission",
          "lambda:AddPermission",
          "lamda:CreateAlias",
          "lambda:CreateEventSourceMapping",

        ]
        Effect   = "Allow",
        Resource = "*"
      },
    ]
  })
}