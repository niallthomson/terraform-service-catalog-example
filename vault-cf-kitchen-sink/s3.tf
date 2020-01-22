resource "aws_s3_bucket" "bucket" {
  bucket = "instance-${var.service_instance_id}"
  acl    = "private"
  
  force_destroy = "true"
}

output "bucket_name" {
  value = "${aws_s3_bucket.bucket.bucket}"
}