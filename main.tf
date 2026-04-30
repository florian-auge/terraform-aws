provider "aws" {
  region = "eu-west-3"
}
resource "aws_instance" "mon_serveur" {
  ami           = "ami-0be40a46b4111e7f5"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.sg_florian.id]
  key_name = aws_key_pair.cle_florian.key_name
  
  tags = {
    Name = "terraform-florian"
  

  }
}
resource "aws_security_group" "sg_florian" {
  name = "terraform-florian-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["82.65.16.6/32"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_key_pair" "cle_florian" {
  key_name   = "cle-terraform-florian"
  public_key = file("~/.ssh/cle-florian.pub")
}