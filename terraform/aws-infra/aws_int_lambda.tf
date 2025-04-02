data "archive_file" "aws_int_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../../backend/lambda-code/aws_int_lambda_code.py"
  output_path = "/tmp/aws_int_lambda_code.zip"
}

resource "aws_lambda_function" "aws_int_lambda" {
  function_name    = "${var.project}-lambda-function"
  role             = aws_iam_role.aws_int_lambda_iam_role.arn
  handler          = "aws_int_lambda_code.lambda_handler"
  runtime          = "python3.11"
  layers           = [aws_lambda_layer_version.aws_int_lambda_layer.arn]
  timeout          = 30
  memory_size      = 128
  filename         = data.archive_file.aws_int_lambda_zip.output_path
  source_code_hash = data.archive_file.aws_int_lambda_zip.output_base64sha512

}

resource "aws_iam_role" "aws_int_lambda_iam_role" {
  name               = "${var.project}-lambda-iam-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_lambda_layer_version" "aws_int_lambda_layer" {
  filename   = "lambda_layer.zip"
  layer_name = "${var.project}-lambda-layer"
  source_code_hash = filebase64sha256("lambda_layer.zip")

  compatible_runtimes = ["python3.11"]
}