# terraform-aws-lambda

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.4.2 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.47.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.execution_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.execution_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_event_source_mapping.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_function.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [random_uuid.package_uuid](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [archive_file.package](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.execution_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | The environment variables of the Lambda function. | `map(string)` | `{}` | no |
| <a name="input_event_mapping"></a> [event\_mapping](#input\_event\_mapping) | Map of source event configurations for the Lambda function.<br><br>  Subargument Reference:<br><br>  - `batch_size` - (optional) Maximum batch size that Lambda will retrieve events from the event source.  Defaults to `100`, except for SQS which defaults to `10`.<br>  - `bisect_batch_on_function_error` - (optional) If the function returns an error, split the batch in two and retry. Defaults to `false`.  Only available for DynamoDB and Kinesis.<br>  - `destination_arn` - (optional) Amazon SQS Queue, Amazon SNS Topic, or Amazon S3 Bucket (Kafka only) ARN destination for failed records.  Only available for stream sources (DynamoDB and Kinesis) and Kafka sources (Amazon MSK or Self-managed Apache Kafka).<br>  - `enabled` - (optional) If the event mapping is enabled.  Defaults to `true`.<br>  - `function_name` - (required) The name of the Lambda function.<br>  - `function_response_types` - (optional) A list of Lambda function response types.  Defaults to `[]`.  Only available for SQS and stream sources (DynamoDB and Kinesis).  Valid values: `ReportBatchItemFailures`.<br>  - `kafka_consumer_group_id` - (optional) The Kafka consumer group ID.  Only available for Kafka sources (Amazon MSK or Self-managed Apache Kafka).<br>  - `kafka_self_managed_source_endpoints` - (optional) A list of self-managed Apache Kafka endpoints.  Coinflicts with `source_arn`.<br>  - `maximum_batching_window_in_seconds` - (optional) The maximum amount of time to gather records before invoking the function, in seconds (between 0 and 300).  Defaults to `0`.  Only available for stream sources (DynamoDB and Kinesis) and SQS.<br>  - `maximum_record_age_in_seconds` - (optional) The maximum age of a record that Lambda sends to a function for processing, in seconds.  Only available for stream sources (DynamoDB and Kinesis).  Must be either -1 (indefinite and default) or between 60 and 604800 (7 days), inclusive.<br>  - `maximum_retry_attempts` - (optional) The maximum number of times to retry when the function returns an error.  Only available for stream sources (DynamoDB and Kinesis).  Must be between `-1` (indefinite) and `10000`.<br>  - `parallelization_factor` - (optional) The number of batches to process from each shard concurrently.  Only available for stream sources (DynamoDB and Kinesis).  Must be between `1` (default) and `10`.<br>  - `queues` - (optional) The name of the Amazon MQ broker destination queue to consume.  Only available for MQ sources.  The list must ocntain exactly one queue name.<br>  - `source_arn` - (optional) The ARN of the event source.  Conflicts with `kafka_self_managed_source_endpoints`.<br>  - `starting_position` - (optional) The position in the stream where AWS Lambda should start reading.  Must be one of `AT_TIMESTAMP` (Kinesis only), `LATEST`, or `TRIM_HORIZON` if getting events from Kinesis, DynamoDB, MSK, or Self-managed Apache Kafka.  Must not be provided if getting events from SQS.<br>  - `starting_position_timestamp` - (optional) The timestamp in RFC3339 format of the data record which to start reading when using `AT_TIMESTAMP` for `starting_position`.  Only available if `starting_position` is `AT_TIMESTAMP`.<br>  - `topics` - (optional) A list of Kafka topic names.  Only available for Amazon MSK.  A single topic must be specified.<br>  - `tumbling_window_in_seconds` - (optional) The duration of the tumbling window in seconds.  Only available for stream sources (DynamoDB and Kinesis).  Must be between 1 and 900. | <pre>map(object({<br>    batch_size                          = optional(number, 100)<br>    bisect_batch_on_function_error      = optional(bool, false)<br>    destination_arn                     = optional(string, null)<br>    enabled                             = optional(bool, true)<br>    function_name                       = string<br>    function_response_types             = optional(list(string), [])<br>    kafka_consumer_group_id             = optional(string, null)<br>    kafka_self_managed_source_endpoints = optional(list(string), [])<br>    maximum_batching_window_in_seconds  = optional(number, null)<br>    maximum_record_age_in_seconds       = optional(number, -1)<br>    maximum_retry_attempts              = optional(number, -1)<br>    parallelization_factor              = optional(number, 1)<br>    queues                              = optional(list(string), [])<br>    source_arn                          = optional(string, null)<br>    starting_position                   = optional(string, null)<br>    starting_position_timestamp         = optional(string, null)<br>    topics                              = optional(list(string), [])<br>    tumbling_window_in_seconds          = optional(number, null)<br>  }))</pre> | `{}` | no |
| <a name="input_handler"></a> [handler](#input\_handler) | The handler of the Lambda function | `string` | n/a | yes |
| <a name="input_image_uri"></a> [image\_uri](#input\_image\_uri) | The container image URI of the Lambda function. If this is set, the package\_file, source\_dir, and source\_file variables are ignored. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the Lambda function (required). | `string` | n/a | yes |
| <a name="input_package_file"></a> [package\_file](#input\_package\_file) | Existing package file of the Lambda function. If this is set, the image\_uri, source\_dir, and source\_file variables are ignored. | `string` | `null` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | The runtime of the Lambda function | `string` | n/a | yes |
| <a name="input_source_dir"></a> [source\_dir](#input\_source\_dir) | The directory of the Lambda function's source code. If this is set, the image\_uri, package\_file, and source\_file variable are ignored. | `string` | `null` | no |
| <a name="input_source_file"></a> [source\_file](#input\_source\_file) | The file of the Lambda function's source code. If this is set, the image\_uri, package\_file, and source\_dir variables are ignored. | `string` | `null` | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | Lambda configuration for VPC connectivity. | <pre>object({<br>    ipv6_allowed_for_dual_stack = optional(bool, false)<br>    security_group_ids          = optional(list(string), [])<br>    subnet_ids                  = optional(list(string), [])<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda"></a> [lambda](#output\_lambda) | All lambda attributes |
| <a name="output_source_event_mapping"></a> [source\_event\_mapping](#output\_source\_event\_mapping) | All source event mapping attributes |
<!-- END_TF_DOCS -->