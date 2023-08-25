data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]  # Canonical owner ID
}

# EC2 instance configuration
resource "aws_instance" "honeypot_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_pair_name
  subnet_id     = var.pub_honeypot_subnet_id
  vpc_security_group_ids = [var.honeypot_security_group_id]
  associate_public_ip_address = true
}
