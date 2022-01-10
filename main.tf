provider "aws" {
  region  = ""
  access_key = ""
  secret_key = ""
}

resource "aws_lb" "alb" {
  name               = "production-alb-tf"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["", ""] //Please specify id of 2 subnets in two different availability zones 

  enable_deletion_protection = true

  access_logs {
    bucket  = aws_s3_bucket.logs.bucket
    prefix  = "production-lb"
    enabled = true
  }

  tags = {
    Environment = "production"
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "" //Please write a name for s3 bucket
  acl    = "public-read-write"
  force_destroy = true
  lifecycle_rule {
    id      = "lifeio-production-lb-access-logs"
    enabled = true

    prefix = "production-lb/"

    tags = {
      rule      = "log"
      autoclean = "true"
      Environment = "production"
    }

    expiration {
      days = 365
    }
   }
  }
resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id
  policy = data.aws_iam_policy_document.public-read-write.json
  }


data "aws_iam_policy_document" "public-read-write" {
    policy_id = "s3_bucket_lb_logs"

    statement {
      actions = [
        "s3:PutObject"]
      effect = "Allow"
      resources = [
        aws_s3_bucket.logs.arn,
        "${aws_s3_bucket.logs.arn}/*",
      ]

      principals {
        identifiers = [""] //Please specify id of your aws role
        type        = "AWS"
      }
    }

    statement {
      actions = [
        "s3:PutObject"
      ]
      effect = "Allow"
      resources = [
          aws_s3_bucket.logs.arn,
          "${aws_s3_bucket.logs.arn}/*"]
      principals {
        identifiers = ["delivery.logs.amazonaws.com"]
        type        = "Service"
      }
    }


    statement {
      actions = [
        "s3:GetBucketAcl"
      ]
      effect = "Allow"
      resources = [
          aws_s3_bucket.logs.arn,
          "${aws_s3_bucket.logs.arn}/*"]
      principals {
        identifiers = ["delivery.logs.amazonaws.com"]
        type        = "Service"
      }
    }
  }