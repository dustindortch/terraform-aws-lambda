output "lambda" {
  description = "All lambda attributes"
  value       = aws_lambda_function.lambda
}

output "source_event_mapping" {
  description = "All source event mapping attributes"
  value       = aws_lambda_event_source_mapping.lambda
}
