variable "rds_instance" {
  description = "Please enter the RDS Instance Name for which the alarms will be created"
  type        = string
  default     = "database-1"
}
variable "topic_name" {
  description = "Topic Name"
  type = string
  default = "rds-topic"
}
variable "sns_subscription_email_address_list" {
  type = list(string)
  default = ["", ""] ### Add the email addresses to which alerts to be sent
}
variable "sns_subscription_protocol" {
	default = "email"
}
