resource "aws_sqs_queue" "sqs_client" {
  name                        = "sqs_queue_${terraform.workspace}.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
}


// refinement needed for policy- not needed for now//
# resource "aws_sqs_queue_policy" "my_sqs_policy" {
#   queue_url = aws_sqs_queue.sqs_client.id
#   policy    = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Id": "sqspolicy",
#   "Statement": [
#     {
#       "Sid": "First",
#       "Effect": "Allow",
#       "Principal": "*",
#       "Action": "SQS:*",
#       "Resource": "*"
#     }
#   ]
# }
# POLICY
# }

