provider "aws" {}

resource "aws_s3_bucket" "my_bucket" {
    bucket_prefix = "terraform-my-bucket-"
    acl = "private"

    versioning {
        enabled = true
    }
}

resource "aws_s3_bucket" "my_bucket_public" {
    bucket_prefix = "terraform-my-bucket-"
    acl = "public-read"

    versioning {
        enabled = false
    }
}

resource "aws_s3_bucket_policy" "read_only_bucket_policy" {
    bucket = aws_s3_bucket.my_bucket_public.id

    policy = <<POLICY
{
      "Version":"2012-10-17",
      "Statement":[
      {
        "Sid":"PublicRead",
        "Effect":"Allow",
        "Principal": "*",
        "Action":["s3:GetObject","s3:GetObjectVersion"],
        "Resource":["${aws_s3_bucket.my_bucket_public.arn}/*"]
      }
     ]
}
    POLICY
}