
resource "aws_cloudwatch_event_rule" "cloudwatch_event" {
  for_each            = local.scheduled_jobs
  name                = "${local.application_name}${each.value.name}"
  description         = each.value.description
  schedule_expression = each.value.schedule_expression
}

resource "aws_cloudwatch_event_target" "event_target" {
  for_each = local.scheduled_jobs
  rule     = aws_cloudwatch_event_rule.cloudwatch_event[each.key].name
  arn      = aws_lambda_function.lambda_function[each.value.function].arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  for_each      = local.scheduled_jobs
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function[each.value.function].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cloudwatch_event[each.key].arn
}
