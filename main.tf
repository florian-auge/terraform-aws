provider "aws" {
  region = "eu-west-3"
}
resource "aws_instance" "mon_serveur" {
  ami           = "ami-0be40a46b4111e7f5"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.sg_florian.id]
  key_name = aws_key_pair.cle_florian.key_name
  iam_instance_profile   = "ec2-s3-role"
  subnet_id = aws_subnet.mon_vpc_subnet.id
  
  tags = {
    Name = "terraform-florian"
  

  }
}
resource "aws_security_group" "sg_florian" {
  name = "terraform-florian-sg"
  vpc_id = aws_vpc.mon_vpc.id

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
output "ec2_public_ip" {
  value = aws_eip.eip_instance.public_ip
}
resource "local_file" "ansible_inventory" {
  content  = "[ec2]\n${aws_eip.eip_instance.public_ip} ansible_ssh_private_key_file=~/.ssh/cle-florian.pem\n"
  filename = "../ansible-test/inventory.ini"
}
resource "aws_vpc" "mon_vpc" {
  cidr_block = "10.0.0.0/16"
}
resource "aws_subnet" "mon_vpc_subnet" {
  vpc_id = aws_vpc.mon_vpc.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
}
resource "aws_internet_gateway" "mon_vpc_gateway" {
  vpc_id = aws_vpc.mon_vpc.id
}
resource "aws_route_table" "ma_route_table" {
  vpc_id = aws_vpc.mon_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mon_vpc_gateway.id
  }
}
resource "aws_route_table_association" "mon_nom" {
  subnet_id      = aws_subnet.mon_vpc_subnet.id
  route_table_id = aws_route_table.ma_route_table.id
}
resource "aws_eip" "eip_instance" {
  instance = aws_instance.mon_serveur.id
  domain = "vpc"
}