variable "name" {
  description = "The name of the Lambda function (required)."
  nullable    = false
  type        = string
}

variable "environment_variables" {
  default     = {}
  description = "The environment variables of the Lambda function."
  nullable    = false
  type        = map(string)

}

variable "image_uri" {
  default     = null
  description = "The container image URI of the Lambda function. If this is set, the package_file, source_dir, and source_file variables are ignored."
  type        = string
}

variable "package_file" {
  default     = null
  description = "Existing package file of the Lambda function. If this is set, the image_uri, source_dir, and source_file variables are ignored."
  type        = string
}

variable "source_dir" {
  default     = null
  description = "The directory of the Lambda function's source code. If this is set, the image_uri, package_file, and source_file variable are ignored."
  type        = string
}

variable "source_file" {
  default     = null
  description = "The file of the Lambda function's source code. If this is set, the image_uri, package_file, and source_dir variables are ignored."
  type        = string
}

variable "handler" {
  description = "The handler of the Lambda function"
  type        = string
}

variable "runtime" {
  description = "The runtime of the Lambda function"
  type        = string

  # Use these Bash commands to refresh the list of available runtimes for the condition:
  # RuntimeVersionsURL="https://raw.githubusercontent.com/boto/botocore/develop/botocore/data/lambda/2015-03-31/service-2.json"
  # curl -s $RuntimeVersionsURL | jq -r '.shapes.Runtime.enum[]' | sort | uniq | awk -F, -v OFS='","' -v q='"' '{$1=$1; print q $0 q}' | awk '{printf "%s%s",sep,$0; sep=",\n"} END{print ""}'

  # Next, use the following Bash command to generate the list of runtimes for the error_message:
  # curl -s $RuntimeVersionsURL | jq -r '.shapes.Runtime.enum[]' | sort | uniq | awk -F, -v OFS='","' -v q='\\"' '{$1=$1; print q $0 q}' | awk '{printf "%s%s",sep,$0; sep=", "} END{print ""}'
  validation {
    condition = contains(
      [
        "dotnet6",
        "dotnet8",
        "dotnetcore1.0",
        "dotnetcore2.0",
        "dotnetcore2.1",
        "dotnetcore3.1",
        "go1.x",
        "java11",
        "java17",
        "java21",
        "java8",
        "java8.al2",
        "nodejs",
        "nodejs10.x",
        "nodejs12.x",
        "nodejs14.x",
        "nodejs16.x",
        "nodejs18.x",
        "nodejs20.x",
        "nodejs4.3",
        "nodejs4.3-edge",
        "nodejs6.10",
        "nodejs8.10",
        "provided",
        "provided.al2",
        "provided.al2023",
        "python2.7",
        "python3.10",
        "python3.11",
        "python3.12",
        "python3.6",
        "python3.7",
        "python3.8",
        "python3.9",
        "ruby2.5",
        "ruby2.7",
        "ruby3.2",
        "ruby3.3"
      ], var.runtime
    )
    error_message = "The value of \"runtime\" can only be one of the following values: \"dotnet6\", \"dotnet8\", \"dotnetcore1.0\", \"dotnetcore2.0\", \"dotnetcore2.1\", \"dotnetcore3.1\", \"go1.x\", \"java11\", \"java17\", \"java21\", \"java8\", \"java8.al2\", \"nodejs\", \"nodejs10.x\", \"nodejs12.x\", \"nodejs14.x\", \"nodejs16.x\", \"nodejs18.x\", \"nodejs20.x\", \"nodejs4.3\", \"nodejs4.3-edge\", \"nodejs6.10\", \"nodejs8.10\", \"provided\", \"provided.al2\", \"provided.al2023\", \"python2.7\", \"python3.10\", \"python3.11\", \"python3.12\", \"python3.6\", \"python3.7\", \"python3.8\", \"python3.9\", \"ruby2.5\", \"ruby2.7\", \"ruby3.2\", \"ruby3.3\""
  }
}

variable "event_mapping" {
  default     = {}
  description = <<EOF
  Map of source event configurations for the Lambda function.

  Subargument Reference:

  - `batch_size` - (optional) Maximum batch size that Lambda will retrieve events from the event source.  Defaults to `100`, except for SQS which defaults to `10`.
  - `bisect_batch_on_function_error` - (optional) If the function returns an error, split the batch in two and retry. Defaults to `false`.  Only available for DynamoDB and Kinesis.
  - `destination_arn` - (optional) Amazon SQS Queue, Amazon SNS Topic, or Amazon S3 Bucket (Kafka only) ARN destination for failed records.  Only available for stream sources (DynamoDB and Kinesis) and Kafka sources (Amazon MSK or Self-managed Apache Kafka).
  - `enabled` - (optional) If the event mapping is enabled.  Defaults to `true`.
  - `function_name` - (required) The name of the Lambda function.
  - `function_response_types` - (optional) A list of Lambda function response types.  Defaults to `[]`.  Only available for SQS and stream sources (DynamoDB and Kinesis).  Valid values: `ReportBatchItemFailures`.
  - `kafka_consumer_group_id` - (optional) The Kafka consumer group ID.  Only available for Kafka sources (Amazon MSK or Self-managed Apache Kafka).
  - `kafka_self_managed_source_endpoints` - (optional) A list of self-managed Apache Kafka endpoints.  Coinflicts with `source_arn`.
  - `maximum_batching_window_in_seconds` - (optional) The maximum amount of time to gather records before invoking the function, in seconds (between 0 and 300).  Defaults to `0`.  Only available for stream sources (DynamoDB and Kinesis) and SQS.
  - `maximum_record_age_in_seconds` - (optional) The maximum age of a record that Lambda sends to a function for processing, in seconds.  Only available for stream sources (DynamoDB and Kinesis).  Must be either -1 (indefinite and default) or between 60 and 604800 (7 days), inclusive.
  - `maximum_retry_attempts` - (optional) The maximum number of times to retry when the function returns an error.  Only available for stream sources (DynamoDB and Kinesis).  Must be between `-1` (indefinite) and `10000`.
  - `parallelization_factor` - (optional) The number of batches to process from each shard concurrently.  Only available for stream sources (DynamoDB and Kinesis).  Must be between `1` (default) and `10`.
  - `queues` - (optional) The name of the Amazon MQ broker destination queue to consume.  Only available for MQ sources.  The list must ocntain exactly one queue name.
  - `source_arn` - (optional) The ARN of the event source.  Conflicts with `kafka_self_managed_source_endpoints`.
  - `starting_position` - (optional) The position in the stream where AWS Lambda should start reading.  Must be one of `AT_TIMESTAMP` (Kinesis only), `LATEST`, or `TRIM_HORIZON` if getting events from Kinesis, DynamoDB, MSK, or Self-managed Apache Kafka.  Must not be provided if getting events from SQS.
  - `starting_position_timestamp` - (optional) The timestamp in RFC3339 format of the data record which to start reading when using `AT_TIMESTAMP` for `starting_position`.  Only available if `starting_position` is `AT_TIMESTAMP`.
  - `topics` - (optional) A list of Kafka topic names.  Only available for Amazon MSK.  A single topic must be specified.
  - `tumbling_window_in_seconds` - (optional) The duration of the tumbling window in seconds.  Only available for stream sources (DynamoDB and Kinesis).  Must be between 1 and 900.
  EOF
  type = map(object({
    batch_size                          = optional(number, 100)
    bisect_batch_on_function_error      = optional(bool, false)
    destination_arn                     = optional(string, null)
    enabled                             = optional(bool, true)
    function_name                       = string
    function_response_types             = optional(list(string), [])
    kafka_consumer_group_id             = optional(string, null)
    kafka_self_managed_source_endpoints = optional(list(string), [])
    maximum_batching_window_in_seconds  = optional(number, null)
    maximum_record_age_in_seconds       = optional(number, -1)
    maximum_retry_attempts              = optional(number, -1)
    parallelization_factor              = optional(number, 1)
    queues                              = optional(list(string), [])
    source_arn                          = optional(string, null)
    starting_position                   = optional(string, null)
    starting_position_timestamp         = optional(string, null)
    topics                              = optional(list(string), [])
    tumbling_window_in_seconds          = optional(number, null)
  }))

  # one of source_arn or kafka_self_managed_source_endpoints must be provided
  validation {
    condition = alltrue([
      for k, v in var.event_mapping : sum(
        v.source_arn != null ? 1 : 0,
        length(v.kafka_self_managed_source_endpoints) > 0 ? 1 : 0
      ) == 1
    ])
    error_message = "One of `source_arn` or `kafka_self_managed_source_endpoints` must be provided."
  }

  # bisect_batch_on_function_error is only available for DynamoDB and Kinesis event sources
  validation {
    condition = alltrue([
      for k, v in var.event_mapping : anytrue([
        !v.bisect_batch_on_function_error,
        alltrue([
          v.bisect_batch_on_function_error,
          contains([
            "dynamodb",
            "kinesis"
          ], try(provider::aws::arn_parse(v.source_arn).service, ""))
        ])
      ])
    ])
    error_message = "`bisect_batch_on_function_error` is only available for DynamoDB and Kinesis event sources."
  }

  # destination_arn is only available for stream sources (DynamoDB and Kinesis) and Kafka sources (Amazon MSK or Self-managed Apache Kafka) for destinations of SQS, SNS, or S3 (only for Kafka).
  validation {
    condition = alltrue([
      for k, v in var.event_mapping : anytrue([
        v.destination_arn == null,
        alltrue([
          contains([
            "sns",
            "sqs"
          ], try(provider::aws::arn_parse(v.destination_arn).service, "")),
          contains([
            "dynamodb",
            "kafka",
            "kinesis"
          ], try(provider::aws::arn_parse(v.source_arn).service, ""))
        ]),
        alltrue([
          try(provider::aws::arn_parse(v.destination_arn).service, "") == "s3",
          try(provider::aws::arn_parse(v.source_arn).service, "") == "kafka"
        ])
      ])
    ])
    error_message = "`destination_arn` is only available for stream sources (DynamoDB and Kinesis) and Kafka (Amazon MSK or Self-managed Apache Kafka) sources for destinations of SQS, SNS, or S3 (only for Kafka)."
  }

  # function_response_types is only available for SQS and stream sources (DynamoDB and Kinesis) with a valid value of ReportBatchItemFailures or an empty list.
  # https://docs.aws.amazon.com/lambda/latest/dg/with-ddb.html#services-ddb-batchfailurereporting
  validation {
    condition = alltrue([
      for k, v in var.event_mapping : anytrue([
        length(v.function_response_types) == 0,
        alltrue([
          for i in v.function_response_types : alltrue([
            i == "ReportBatchItemFailures",
            contains([
              "dynamodb",
              "kinesis",
              "sqs"
            ], try(provider::aws::arn_parse(v.source_arn).service, ""))
          ])
        ])
      ])
    ])
    error_message = "`function_response_types` is only available for SQS and stream sources (DynamoDB and Kinesis) with a valid value of `ReportBatchItemFailures` or an empty list."
  }

  # kafka_consumer_group_id is only available for Kafka sources (Amazon MSK or Self-managed Apache Kafka).
  validation {
    condition = alltrue([
      for k, v in var.event_mapping : anytrue([
        v.kafka_consumer_group_id == null,
        alltrue([
          v.kafka_consumer_group_id != null,
          anytrue([
            contains([
              "kafka"
            ], try(provider::aws::arn_parse(v.source_arn).service, "")),
            length(v.kafka_self_managed_source_endpoints) > 0
          ])
        ])
      ])
    ])
    error_message = "`kafka_consumer_group_id` is only available for Kafka sources (Amazon MSK or Self-managed Apache Kafka)."
  }

  # maximum_batching_window_in_seconds is only available for stream sources (DynamoDB and Kinesis) and SQS.
  validation {
    condition = alltrue([
      for k, v in var.event_mapping : anytrue([
        v.maximum_batching_window_in_seconds == null,
        alltrue([
          v.maximum_batching_window_in_seconds >= 0,
          v.maximum_batching_window_in_seconds <= 300,
          anytrue([
            contains([
              "dynamodb",
              "kinesis",
              "sqs"
            ], try(provider::aws::arn_parse(v.source_arn).service, ""))
          ])
        ])
      ])
    ])
    error_message = "`maximum_batching_window_in_seconds` is only available for stream sources (DynamoDB and Kinesis) and SQS.  Valid values are between 0 and 300."
  }

  # maximum_record_age_in_seconds is only available for stream sources (DynamoDB and Kinesis).  Must be either -1 (indefinite and default) or between 60 and 604800 (7 days), inclusive.
  validation {
    condition = alltrue([
      for k, v in var.event_mapping : anytrue([
        v.maximum_record_age_in_seconds == -1,
        alltrue([
          v.maximum_record_age_in_seconds >= 60,
          v.maximum_record_age_in_seconds <= 604800,
          contains([
            "dynamodb",
            "kinesis"
          ], try(provider::aws::arn_parse(v.source_arn).service, ""))
        ])
      ])
    ])
    error_message = "`maximum_record_age_in_seconds` is only available for stream sources (DynamoDB and Kinesis).  Must be either -1 (indefinite and default) or between 60 and 604800 (7 days), inclusive."
  }

  # maximum_retry_attempts is only available for stream sources (DynamoDB and Kinesis).  Must be between -1 (indefinite) and 10000.
  validation {
    condition = alltrue([
      for k, v in var.event_mapping : anytrue([
        v.maximum_retry_attempts == -1,
        alltrue([
          v.maximum_retry_attempts >= -1,
          v.maximum_retry_attempts <= 10000,
          contains([
            "dynamodb",
            "kinesis"
          ], try(provider::aws::arn_parse(v.source_arn).service, ""))
        ])
      ])
    ])
    error_message = "`maximum_retry_attempts` is only available for stream sources (DynamoDB and Kinesis).  Must be between `-1` (indefinite) and `10000`."
  }

  # parallelization_factor is only available for stream sources (DynamoDB and Kinesis).  Must be between 1 (default) and 10.
  validation {
    condition = alltrue([
      for k, v in var.event_mapping : anytrue([
        v.parallelization_factor == 1,
        alltrue([
          v.parallelization_factor >= 1,
          v.parallelization_factor <= 10,
          contains([
            "dynamodb",
            "kinesis"
          ], try(provider::aws::arn_parse(v.source_arn).service, ""))
        ])
      ])
    ])
    error_message = "`parallelization_factor` is only available for stream sources (DynamoDB and Kinesis).  Must be between `1` (default) and `10`."
  }

  # queues is only available for MQ sources.  The list must contain exactly one queue name.
  validation {
    condition = alltrue([
      for k, v in var.event_mapping : anytrue([
        length(v.queues) == 0,
        alltrue([
          length(v.queues) == 1,
          contains([
            "mq"
          ], try(provider::aws::arn_parse(v.source_arn).service, ""))
        ])
      ])
    ])
    error_message = "`queues` is only available for MQ sources.  The list must contain exactly one queue name."
  }

  # starting_position must be one of AT_TIMESTAMP (Kinesis only), LATEST, or TRIM_HORIZON if getting events form Kinesis, DynamoDB, or Kafka.  Must not be provided if getting events from SQS.
  validation {
    condition = alltrue([
      for k, v in var.event_mapping : anytrue([
        alltrue([
          v.starting_position == null,
          !contains([
            "dynamodb",
            "kinesis",
            "kafka"
          ], try(provider::aws::arn_parse(v.source_arn).service, "")),
          length(v.kafka_self_managed_source_endpoints) == 0
        ]),
        alltrue([
          v.starting_position == "AT_TIMESTAMP",
          try(provider::aws::arn_parse(v.source_arn).service, "") == "kinesis"
        ]),
        alltrue([
          contains(["LATEST", "TRIM_HORIZON"], v.starting_position),
          anytrue([
            contains([
              "dynamodb",
              "kinesis",
              "kafka"
            ], try(provider::aws::arn_parse(v.source_arn).service, "")),
            length(v.kafka_self_managed_source_endpoints) > 0
          ])
        ]),
      ])
    ])
    error_message = "`starting_position` must be one of `AT_TIMESTAMP` (Kinesis only), `LATEST`, or `TRIM_HORIZON` if getting events from Kinesis, DynamoDB, or Kafka.  Must not be provided if getting events from SQS."
  }

  # starting_position_timestamp is only available if starting_position is AT_TIMESTAMP.
  validation {
    condition = alltrue([
      for k, v in var.event_mapping : anytrue([
        v.starting_position_timestamp == null,
        alltrue([
          v.starting_position == "AT_TIMESTAMP",
          v.starting_position_timestamp != null
        ])
      ])
    ])
    error_message = "`starting_position_timestamp` is only available if `starting_position` is `AT_TIMESTAMP`."
  }

  # starting_position_timestamp must be in RFC3339 format.
  validation {
    condition = alltrue([
      for k, v in var.event_mapping : anytrue([
        v.starting_position_timestamp == null,
        alltrue([
          v.starting_position_timestamp != null,
          can(formatdate("DD MMM YYYY hh:mm ZZZ", v.starting_position_timestamp))
        ])
      ])
    ])
    error_message = "`starting_position_timestamp` must be in RFC3339 format."
  }

  # topics is only available for Amazon MSK.  A single topic must be specified.
  validation {
    condition = alltrue([
      for k, v in var.event_mapping : anytrue([
        alltrue([
          length(v.topics) == 0,
          try(provider::aws::arn_parse(v.source_arn).service, "") != "kafka"
        ]),
        alltrue([
          length(v.topics) == 1,
          try(provider::aws::arn_parse(v.source_arn).service, "") == "kafka"
        ])
      ])
    ])
    error_message = "`topics` is only available for Amazon MSK.  A single topic must be specified."
  }

  # tumbling_window_in_seconds is only available for stream sources (DynamoDB and Kinesis).  Must be between 1 and 900.
  validation {
    condition = alltrue([
      for k, v in var.event_mapping : anytrue([
        v.tumbling_window_in_seconds == null,
        alltrue([
          v.tumbling_window_in_seconds >= 1,
          v.tumbling_window_in_seconds <= 900,
          contains([
            "dynamodb",
            "kinesis"
          ], try(provider::aws::arn_parse(v.source_arn).service, ""))
        ])
      ])
    ])
    error_message = "`tumbling_window_in_seconds` is only available for stream sources (DynamoDB and Kinesis).  Must be between 1 and 900."
  }
}

variable "vpc_config" {
  default     = null
  description = "Lambda configuration for VPC connectivity."
  type = object({
    ipv6_allowed_for_dual_stack = optional(bool, false)
    security_group_ids          = optional(list(string), [])
    subnet_ids                  = optional(list(string), [])
  })
}
