#Dynamo Lambda
resource "aws_iam_role" "iam_role_for_dynamo" {
  name               = "DynamodbScan2"
  assume_role_policy = file("${path.module}/policies/LambdaAssume.pol")
}

resource "aws_iam_role_policy" "iam_role_policy_for_dynamo" {
  name   = "DynamodbScan"
  role   = aws_iam_role.iam_role_for_dynamo.id
  policy = file("${path.module}/policies/LambdaExecution.pol")
}

#Athena createion Lambda

resource "aws_iam_role" "iam_role_for_athena" {
  name               = "athena"
  assume_role_policy = file("${path.module}/policies/LambdaAssume.pol")
}

resource "aws_iam_role_policy" "iam_role_policy_for_athena" {
  name   = "athena"
  role   = aws_iam_role.iam_role_for_athena.id
  policy = file("${path.module}/policies/LambdaAthena.pol")
}

