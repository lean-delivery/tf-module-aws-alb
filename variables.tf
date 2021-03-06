variable "vpc_id" {
  type        = string
  description = "VPC id where the load balancer and other resources will be deployed"
  default     = ""
}

variable "subnets" {
  type        = list(string)
  description = "A list of subnets to associate with the load balancer"
  default     = null
}

variable "project" {
  type        = string
  default     = "project"
  description = "Project name (used for resource naming and tagging)"
}

variable "environment" {
  type        = string
  default     = "test"
  description = "Environment name (used for resource naming and tagging)"
}

variable "enable_logging" {
  type        = bool
  default     = true
  description = "Trigger to enable ALB logging"
}

variable "enable_subdomains" {
  type        = bool
  description = "Trigger to add '*.' before ALB custom domain name"
  default     = false
}

variable "default_load_balancer_is_internal" {
  type        = bool
  description = "Boolean determining if the load balancer is internal or externally facing."
  default     = true
}

variable "force_destroy" {
  type        = bool
  default     = true
  description = "Enforces destruction of S3 bucket with ALB logs"
}

variable "default_http_tcp_listeners_port" {
  type        = number
  default     = 80
  description = "Port of default HTTP listener"
}

variable "default_https_tcp_listeners_port" {
  type        = number
  default     = 443
  description = "Port of default HTTPs listener"
}

variable "default_target_groups_port" {
  type        = number
  default     = 80
  description = "Port of default target group"
}

variable "target_groups_health_check" {
  type        = map(any)
  description = "Target group health check parameters"

  default     = {
    "health_check_path"                = "/healthcheck"
    "health_check_matcher"             = "200"
    "cookie_duration"                  = 86400
    "deregistration_delay"             = 300
    "health_check_interval"            = 10
    "health_check_healthy_threshold"   = 3
    "health_check_port"                = "traffic-port"
    "health_check_timeout"             = 5
    "health_check_unhealthy_threshold" = 3
    "stickiness_enabled"               = true
    "target_type"                      = "instance"
  }
}

variable "default_target_groups_backend_protocol" {
  type        = string
  default     = "HTTP"
  description = "Backend protocol of default target group"
}

variable "acm_cert_domain" {
  type        = string
  description = "Domain name for which ACM certificate was created"
  default     = ""
}

variable "root_domain" {
  type        = string
  default     = ""
  description = "Root domain in which custom DNS record for ALB would be created"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags for resources"
  default     = {}
}

variable "lb_accout_id_per_region" {
  type    = map(string)
  default = {
    "us-east-1"      = "127311923021"
    "us-east-2"      = "033677994240"
    "us-west-1"      = "027434742980"
    "us-west-2"      = "797873946194"
    "ca-central-1"   = "985666609251"
    "eu-central-1"   = "054676820928"
    "eu-west-1"      = "156460612806"
    "eu-west-2"      = "652711504416"
    "eu-west-3"      = "009996457667"
    "ap-northeast-1" = "582318560864"
    "ap-northeast-2" = "600734575887"
    "ap-northeast-3" = "383597477331"
    "ap-southeast-1" = "114774131450"
    "ap-southeast-2" = "783225319266"
    "ap-south-1"     = "718504428378"
    "sa-east-1"      = "507241528517"
    "us-gov-west-1"  = "048591011584"
    "us-gov-east-1"  = "190560391635"
    "cn-north-1"     = "638102146993"
    "cn-northwest-1" = "037604701340"
  }
}

variable "most_recent_certificate" {
  type        = bool
  description = "Trigger to use most recent SSL certificate"
  default     = false
}

variable "alb_logs_lifecycle_rule_enabled" {
  type        = bool
  description = "Enable or disable lifecycle_rule for ALB logs s3 bucket"
  default     = false
}

variable "alb_logs_expiration_days" {
  type        = number
  description = "s3 lifecycle rule expiration period in days"
  default     = 5
}

variable "alb_custom_security_group" {
  type        = bool
  description = "Switch to override default-created security group"
  default     = false
}

variable "alb_custom_security_group_id" {
  type        = string
  description = "Security group ID that override default-created security group"
  default     = "None"
}

variable "cn_acm" {
  type        = bool
  default     = false
  description = "Whether to use acm certificate with AWS China"
}

variable "cn_route53" {
  type        = bool
  default     = false
  description = "Whether to use Route53 in AWS China"
}

variable "alb_custom_route53_record_name" {
  type        = string
  default     = ""
  description = "Custom Route53 record name for ALB"
}

variable "listener_ssl_policy" {
  description = "The security policy if using HTTPS externally on the load balancer. [See](https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html)."
  type        = string
  default     = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
}
