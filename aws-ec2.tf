resource "aws_instance" "app_server" {
  ami           = "ami-0b55fc9b052b03618" #Amazon Linux2 AMI ap-southeast-2
  instance_type = "t2.micro"

  tags = {
    Name = "TerraformAppServerInstance"
  }
}