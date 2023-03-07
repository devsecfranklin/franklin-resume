
/* ******************** AWS CLOUD ********************** 
variable "aws_region" {
  default = "us-west-1"
  type    = string
}

variable "s3_bucket_name" {
  type    = string
  default = "lab-franklin"
}

variable "s3_acl_value" {
  default = "private"
  type    = string
}
resource "aws_s3_bucket" "ps_east_lab_franklin" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = var.s3_bucket_name
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "ps_east_lab_franklin_acl" {
  bucket = aws_s3_bucket.ps_east_lab_franklin.id
  acl    = var.s3_acl_value
}

resource "aws_s3_bucket_versioning" "ps_east_lab_franklin_versioning" {
  bucket = aws_s3_bucket.ps_east_lab_franklin.id
  versioning_configuration {
    status = "Disabled"
  }
}
*/

/*
resource "aws_s3_bucket_server_side_encryption_configuration" "ps_east_lab_franklin_s3_enc" {
  bucket = aws_s3_bucket.ps_east_lab_franklin.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
*/

/*
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.name_prefix}locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
*/

/* policy
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "Statement1",
			"Principal": "*",
			"Effect": "Allow",
			"Action": [
				"s3:*"
			],
			"Resource": [
				"arn:aws:s3:::ps-lab-east-franklin"
			],
			"Condition": {
				"IpAddress": {
					"aws:SourceIp": [
						"68.38.137.81/32"
					]
				}
			}
		}
	]
}
*/
