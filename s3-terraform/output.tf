output "bucket_id" {
    value = aws_s3_bucket.my_bucket.id
}

output "bucket_arn" {
    value = aws_s3_bucket.my_bucket.arn
}

output "bucket_region" {
    value = aws_s3_bucket.my_bucket.region
}

output "bucket_public_id" {
    value = aws_s3_bucket.my_bucket_public.id
}

output "bucket_public_arn" {
    value = aws_s3_bucket.my_bucket_public.arn
}

output "bucket_public_region" {
    value = aws_s3_bucket.my_bucket_public.region
}