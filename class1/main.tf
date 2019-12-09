provider "aws" {
    region = var.aws_region
}

data "aws_subnet_ids" "subnets" {
    vpc_id = var.vpc_id
}


data "aws_ami" "ubuntu" {
most_recent = true

  filter {
    name   = "name"
   values = ["ubuntu/images/hvm-ssd/-*"]
 }

  filter {
   name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# resource "tls_private_key" "server_key" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "aws_key_pair" "server_key" {
#   key_name   = "server_key"
#   public_key = "${tls_private_key.server_key.public_key_openssh}"
# }


resource "aws_instance" "server" {
  count = 1

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  associate_public_ip_address = true

  vpc_security_group_ids = aws_security_group.opsschool_consul
  key_name               = aws_key_pair.consul_key.key_name
  # user_data = "${file("install_ansible.sh")}"
  user_data = "${file("${path.module}/consul-server.sh")}"

#  connection {
#    type        = "ssh"
#    host        = self.public_ip
#    user        = "ubuntu"
#    private_key = "${tls_private_key.consul_key.private_key_pem}"
#  }

  tags = {
    consul_server = "true",
    Name = "Server"
  }
}
