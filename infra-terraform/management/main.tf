provider "aws" {
  region = "us-east-1" 
}

# 1. 建立一個隨機 ID
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# 2. 建立 S3 儲存桶
resource "aws_s3_bucket" "terraform_state" {
  bucket = "mini-finance-tfstate-${random_id.bucket_suffix.hex}"

  lifecycle {
    prevent_destroy = true # 防止誤刪這個核心儲存桶
  }
}

# 3. 開啟版本控制 (可回滾狀態)
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 4. 建立 DynamoDB 用於狀態鎖
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S" # 因為他寫入字串類型是string，故用其他類型會因為船入閣是不對而報錯
  }
}

# 輸出 S3 名稱
output "state_bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}