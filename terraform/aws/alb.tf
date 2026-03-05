# ── Application Load Balancer ────────────────────────────────────────────────
# tfsec:ignore:aws-elb-alb-not-public
# checkov:skip=CKV2_AWS_28:WAF not required for demo
# checkov:skip=CKV_AWS_150:Deletion protection not required for demo
resource "aws_lb" "main" {
  name               = "${var.cluster_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = var.environment == "prod" ? true : false
  drop_invalid_header_fields = true

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.id
    prefix  = "expense-tracker-alb"
    enabled = true
  }

  tags = { Name = "${var.cluster_name}-alb" }
}

# ── S3 bucket for ALB access logs ──────────────────────────────────────────
# tfsec:ignore:aws-s3-enable-bucket-logging
# checkov:skip=CKV2_AWS_62:Event notifications not required for demo
# checkov:skip=CKV2_AWS_61:Lifecycle configuration not required for demo
# checkov:skip=CKV_AWS_144:Cross-region replication not required for demo
# checkov:skip=CKV_AWS_145:KMS encryption not required for demo
# checkov:skip=CKV_AWS_18:Access logging not required for ALB logs bucket itself
resource "aws_s3_bucket" "alb_logs" {
  bucket        = "${var.cluster_name}-alb-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  versioning_configuration { status = "Enabled" }
}

# tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket                  = aws_s3_bucket.alb_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = data.aws_elb_service_account.main.arn }
      Action    = "s3:PutObject"
      Resource  = "${aws_s3_bucket.alb_logs.arn}/expense-tracker-alb/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    }]
  })
}

# ── HTTP Listener (redirect to HTTPS) ───────────────────────────────────────
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# ── Target Groups ────────────────────────────────────────────────────────────
# checkov:skip=CKV_AWS_378:HTTP protocol acceptable for internal target group behind ALB
resource "aws_lb_target_group" "frontend" {
  name        = "${var.cluster_name}-frontend-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
  }
}

# checkov:skip=CKV_AWS_378:HTTP protocol acceptable for internal target group behind ALB
resource "aws_lb_target_group" "backend" {
  name        = "${var.cluster_name}-backend-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
  }
}
