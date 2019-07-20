/*resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "cur-state-machine"
  role_arn = "${aws_iam_role.iam_role_for_dynamo.arn}"

  definition = <<EOF
  {
    "StartAt": "CUR",
    "States": {
      "CUR": {
        "Type": "Task",
        "Resource": "${module.lambda_cur.function_arn}",
        "Next": "Invoke Athea Lambda with retry",
        "Catch": [
            {
               "ErrorEquals": ["States.ALL"],
               "Next": "FailState"
            }
         ]
      },
      "Invoke Athea Lambda with retry": {
        "Type": "Task",
        "Resource": "${aws_lambda_function.athena.arn}",
        "Next": "Athena_Partition",
        "TimeoutSeconds": 90,
         "Retry": [
          {
            "ErrorEquals": [
              "States.ALL"
            ],
            "IntervalSeconds": 86400,
            "BackoffRate": 2,
            "MaxAttempts": 6
          }
        ],
        "Catch": [
          {
            "ErrorEquals": [
              "States.Permissions"
            ],
            "Next": "FailState"
          }
        ]
      },
      "Athena_Partition": {
        "Type": "Task",
        "Resource": "${aws_lambda_function.athena_partition.arn}",
        "Next": "Send message to SNS",
        "Catch": [
            {
               "ErrorEquals": ["States.ALL"],
               "Next": "FailState"
            }
         ]
      },
      "Send message to SNS": {
        "Type": "Task",
        "Resource": "arn:aws:states:::sns:publish",
        "Parameters": {
          "TopicArn": "${module.admin-sns-email-topic.arn}",
          "Message": "Congratulations your CUR file is complete!"
        },
        "Next": "SuccessState",
        "Catch": [
            {
               "ErrorEquals": ["States.ALL"],
               "Next": "FailState"
            }
         ]
      },
      "FailState": {
        "Type": "Fail"
      },
      "SuccessState": {
        "Type": "Succeed"
      }
    }
  }

EOF
}
*/

