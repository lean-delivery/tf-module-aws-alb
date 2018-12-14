locals {
  default_tags = {
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "allow_in80_in443_outALL" {
  name        = "allow-in_80-in_443-out_ALL-${var.project}-${var.environment}"
  description = "Allow inbound traffic on ports 80 and 443"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${local.default_tags}"
}

resource "aws_s3_bucket" "alb-logs" {
  count         = "${ var.enable_logging ? 1 : 0 }"
  bucket        = "${var.project}-${var.environment}-alb-logs"
  acl           = "log-delivery-write"
  force_destroy = "${ lower(var.environment) == "production" ? "false" : var.force_destroy}"

  tags = "${local.default_tags}"
}

data "aws_region" "current" {}

data "aws_iam_policy_document" "alb-logs-policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${element(aws_s3_bucket.alb-logs.*.id, count.index)}/*",
    ]

    principals = {
      type        = "AWS"
      identifiers = ["${lookup(var.lb_accout_id_per_region, data.aws_region.current.name)}"]
    }
  }
}

resource "aws_s3_bucket_policy" "alb-logs" {
  count  = "${ var.enable_logging ? 1 : 0 }"
  bucket = "${element(aws_s3_bucket.alb-logs.*.id, count.index)}"

  policy = "${data.aws_iam_policy_document.alb-logs-policy.json}"
}

data "aws_acm_certificate" "this" {
  domain   = "${var.acm_cert_domain}"
  statuses = ["ISSUED", "PENDING_VALIDATION"]
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "3.5.0"

  load_balancer_name = "${var.project}-${var.environment}"
  security_groups    = ["${aws_security_group.allow_in80_in443_outALL.id}"]
  subnets            = "${var.subnets}"
  vpc_id             = "${var.vpc_id}"

  /////// Configure listeners and target groups ///////
  https_listeners       = "${list(map("certificate_arn", "${data.aws_acm_certificate.this.arn}", "port", "${var.default_https_tcp_listeners_port}"))}"
  https_listeners_count = "${var.default_https_tcp_listeners_count}"

  http_tcp_listeners       = "${list(map("port", "${var.default_http_tcp_listeners_port}", "protocol", "HTTP"))}"
  http_tcp_listeners_count = "${var.default_http_tcp_listeners_count}"

  target_groups       = "${list(map("name", "${var.project}-${var.environment}", "backend_protocol", "${var.default_target_groups_backend_protocol}", "backend_port", "${var.default_target_groups_port}"))}"
  target_groups_count = "${var.default_target_groups_count}"

  logging_enabled = "${var.enable_logging}"
  log_bucket_name = "${aws_s3_bucket.alb-logs.0.id}"
  tags            = "${merge(local.default_tags, var.tags)}"

  target_groups_defaults = "${var.target_groups_defaults}"
}

data "aws_route53_zone" "alb" {
  name = "${var.root_domain}."
}

resource "aws_route53_record" "alb" {
  zone_id = "${data.aws_route53_zone.alb.zone_id}"
  name    = "${var.project}-${var.environment}-${data.aws_region.current.name}.${var.root_domain}"
  type    = "A"

  alias {
    name                   = "${module.alb.dns_name}"
    zone_id                = "${module.alb.load_balancer_zone_id}"
    evaluate_target_health = true
  }
}
