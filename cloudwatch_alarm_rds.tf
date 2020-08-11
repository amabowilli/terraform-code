provider "aws" {
  region = "us-east-1"
}
############## SNS Topic for RDS Monitoring ######################
data "template_file" "aws_cf_sns_stack" {
   template = file("${path.module}/cf_aws_sns_email_stack.json.tpl")
   vars = {
     sns_topic_name        = var.topic_name
     sns_display_name      = var.topic_name
     sns_subscription_list = join(",", formatlist("{\"Endpoint\": \"%s\",\"Protocol\": \"%s\"}",
     var.sns_subscription_email_address_list,
     var.sns_subscription_protocol))
   }
 }
 resource "aws_cloudformation_stack" "sns_topic" {
   name = "snsStack"
   template_body = data.template_file.aws_cf_sns_stack.rendered
   tags = {
     name = "snsStack"
   }
 }
resource "aws_cloudwatch_metric_alarm" "check_rds_cpu_utilization" {
  alarm_name        = format("%s-%s-%s","RDS",var.rds_instance,"CPUUtilization")
  alarm_actions     = [aws_cloudformation_stack.sns_topic.outputs["SNSTopicArn"]]
  alarm_description = "CPU Utilization alarm"
  period              = "300"
  statistic           = "Average"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = "75"
  evaluation_periods  = "1"
  unit = "Percent"
  metric_name = "CPUUtilization"
  namespace = "AWS/RDS"
  dimensions = {
  	DBInstanceIdentifier = var.rds_instance
  }
}
#### Reference for the RDS Database connections based on the RDS Instance type ######
#### https://stackoverflow.com/questions/39705700/value-of-max-connections-in-aws-rds
resource "aws_cloudwatch_metric_alarm" "check_rds_database_connections" {
  alarm_name        = format("%s-%s-%s","RDS",var.rds_instance,"DatabaseConnections")
  alarm_actions     = [aws_cloudformation_stack.sns_topic.outputs["SNSTopicArn"]]
  alarm_description = "Database Connections alarm"
  period              = "300"
  statistic           = "Average"
  comparison_operator = "GreaterThanThreshold"
  threshold           = "50"
  evaluation_periods  = "1"
  unit = "Count"
  metric_name = "DatabaseConnections"
  namespace = "AWS/RDS"
  dimensions = {
  	DBInstanceIdentifier = var.rds_instance
  }
}
###### This is applicable when using the MYSQL Read Replicas ################
# resource "aws_cloudwatch_metric_alarm" "check_rds_database_binlog_diskusage" {
#   alarm_name        = "RDS-BinLogDiskUsage"
#   alarm_actions     = [aws_cloudformation_stack.sns_topic.outputs["SNSTopicArn"]]
#   alarm_description = ""
#   period              = "300"
#   statistic           = "Average"
#   comparison_operator = "GreaterThanThreshold"
#   threshold           = "75"
#   evaluation_periods  = "1"
#   unit = "Bytes"
#   metric_name = "BinLogDiskUsage"
#   namespace = "AWS/RDS"
#   dimensions = {
#   	DBInstanceIdentifier = "database-1"
#   }
# }
resource "aws_cloudwatch_metric_alarm" "check_rds_database_free_memory" {
  alarm_name        = format("%s-%s-%s","RDS",var.rds_instance,"FreeableMemory")
  alarm_actions     = [aws_cloudformation_stack.sns_topic.outputs["SNSTopicArn"]]
  alarm_description = "Free Memory Alarm"
  period              = "300"
  statistic           = "Average"
  comparison_operator = "LessThanThreshold"
  threshold           = "75"
  evaluation_periods  = "1"
  unit = "Bytes"
  metric_name = "FreeableMemory"
  namespace = "AWS/RDS"
  dimensions = {
  	DBInstanceIdentifier = var.rds_instance
  }
}
resource "aws_cloudwatch_metric_alarm" "check_rds_database_diskqueue_depth" {
  alarm_name        = format("%s-%s-%s","RDS",var.rds_instance,"DiskQueueDepth")
  alarm_actions     = [aws_cloudformation_stack.sns_topic.outputs["SNSTopicArn"]]
  alarm_description = "Disk Queue Depth Alarm"
  period              = "300"
  statistic           = "Average"
  comparison_operator = "GreaterThanThreshold"
  threshold           = "10"
  evaluation_periods  = "1"
  unit = "Count"
  metric_name = "DiskQueueDepth"
  namespace = "AWS/RDS"
  dimensions = {
  	DBInstanceIdentifier = var.rds_instance
  }
}
resource "aws_cloudwatch_metric_alarm" "check_rds_database_freestorage_space" {
  alarm_name        = format("%s-%s-%s","RDS",var.rds_instance,"FreeStorageSpace")
  alarm_actions     = [aws_cloudformation_stack.sns_topic.outputs["SNSTopicArn"]]
  alarm_description = "Free Storage Space Alarm"
  period              = "300"
  statistic           = "Average"
  comparison_operator = "LessThanThreshold"
  threshold           = "50"
  evaluation_periods  = "1"
  unit = "Bytes"
  metric_name = "FreeStorageSpace"
  namespace = "AWS/RDS"
  dimensions = {
  	DBInstanceIdentifier = var.rds_instance
  }
} 
