locals {
  s3_image_bucket_name  = local.resource_prefix
  s3_backup_bucket_name = "${local.resource_prefix}-backup-els"
}

resource "aws_s3_bucket" "s3_image" {
  bucket = local.s3_image_bucket_name

  tags = {
    Name = "${local.s3_image_bucket_name}"
  }
}

resource "aws_s3_bucket" "s3_backup" {
  bucket = local.s3_backup_bucket_name

  tags = {
    Name = "${local.s3_backup_bucket_name}"
  }
}
