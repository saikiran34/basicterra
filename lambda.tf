data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "index.js"
  output_path = "payload.zip"
}

#data "aws_iam_role" "GenericLambdaFullAccessRole" {
 # name = "GenericLambdaFullAccessRole"
#}

resource "aws_lambda_function" "fxlink_controllambda" {
  filename         = "payload.zip"
  function_name    = "front_controller_${terraform.workspace}"
  #role             = data.aws_iam_role.GenericLambdaFullAccessRole.name
  role             = "arn:aws:iam::761205816843:role/GenericLambdaFullAccessRole"
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  //source_code_hash = filebase64sha256("payload.zip")

  runtime = "nodejs14.x"
  vpc_config {
    subnet_ids         = [aws_subnet.private1.id, aws_subnet.private2.id, aws_subnet.private3.id]
    security_group_ids = [aws_security_group.VPC_Security_group.id]
  }
  environment {
    variables = {
      "Environment" = "${terraform.workspace}"
    }
  }
}