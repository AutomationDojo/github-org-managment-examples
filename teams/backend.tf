terraform {
  backend "s3" {
    bucket = "terraform-state-bucket"
    key    = "path/to/my/key"
    region = "us-east-1"
  }
}
