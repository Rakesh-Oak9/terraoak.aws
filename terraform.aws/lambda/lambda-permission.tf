resource "aws_lambda_permission" "allow_cloudwatch" {
  action        = "*"   
  function_name = aws_lambda_function.insecure_lambda_SAC.arn 
  principal     = "*"    
  # oak9: Limit access to trusted principals
}