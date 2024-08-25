output "invoke_url" {
  value = aws_api_gateway_deployment.crc-api-deploy.invoke_url
}

output "database_name" {
    value = aws_dynamodb_table.crc-table.name
}