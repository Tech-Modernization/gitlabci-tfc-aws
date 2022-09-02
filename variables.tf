variable "aws_account" {
  description = "AWS Credentials"
  type = object({
    region     = string
    access_key = string
    secret_key = string
    token = string
  })
}