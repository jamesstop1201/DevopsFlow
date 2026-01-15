# 輸出 S3 名稱
output "state_bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}