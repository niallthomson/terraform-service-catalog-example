resource "aws_s3_bucket" "bucket" {
  bucket = "instance-${var.service_instance_id}"
  acl    = "private"
  
  force_destroy = "true"
}

resource "aws_iam_user" "user" {
  name = "instance-${var.service_instance_id}"
}

resource "aws_iam_user_policy" "policy" {
  name = "default"
  user = "${aws_iam_user.user.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [ "s3:*" ],
      "Resource": [
        "${aws_s3_bucket.bucket.arn}",
        "${aws_s3_bucket.bucket.arn}/*"
      ]
    }
  ]
}
EOF
}