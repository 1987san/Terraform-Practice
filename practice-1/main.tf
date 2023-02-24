provider "aws" {
  region = "us-east-1"
}
resource "aws_instance" "WebServer" {
  ami           =  "ami-0557a15b87f6559cf" 
  instance_type = "t2.micro"
  key_name = "tf-key-pair"
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

  user_data_replace_on_change = true

    tags = {
    Name = "WebServer"
  }
}
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_key_pair" "tf-key-pair" {
key_name = "tf-key-pair"
public_key = tls_private_key.rsa.public_key_openssh
}
resource "tls_private_key" "rsa" {
algorithm = "RSA"
rsa_bits  = 4096
}
resource "local_file" "tf-key" {
content  = tls_private_key.rsa.private_key_pem
filename = "tf-key-pair"
}

# variable "server_port" {
#   description = "The port the server will use for HTTP requests"
#   type        = number
# }


output "public_ip" {
  value       = aws_instance.WebServer.public_ip
  description = "The public IP address of the web server"
}
# output "server_port" {
#   value       = TF_VAR.server_port
#   description = "The server port"
# }




