resource "aws_api_gateway_account" "sac_api_gateway_account" {
  
  depends_on = [
    aws_iam_role_policy_attachment.sac_api_gateway_policy_attachment,
    aws_iam_role_policy.sac_api_gateway_role_policy
  ]
}

resource "aws_iam_role" "sac_api_gateway_role" {
  name = "sac-testing-apigw-cloudwatch-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": ["apigateway.amazonaws.com","lambda.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "sac_api_gateway_role_policy" {
  name = "sac-testing-apigw-cloudwatch-role-policy"
  role = aws_iam_role.sac_api_gateway_role.id

  policy = <<EOF
  # oak9: Explicitly define resources in roles
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "sac_api_gateway_policy_attachment" {
  role       = aws_iam_role.sac_api_gateway_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}