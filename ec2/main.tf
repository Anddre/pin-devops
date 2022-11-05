
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Generar las llaves
resource "aws_key_pair" "key_pair" {
  key_name   = "key"
  public_key = tls_private_key.key.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.key.private_key_pem}' > ./key.pem"
  }
}

# Crear una instancia ec2 con os ubuntu 20.04
resource "aws_instance" "node" {
  instance_type          = "t2.micro" # free instance
# ami                    = "ami-0d527b8c289b4af7f"
  ami                    = "ami-0066d036f9777ec38"
  key_name               = aws_key_pair.key_pair.id
  vpc_security_group_ids = [var.public_sg]
  subnet_id              = var.public_subnet

 # iam_instance_profile = "${aws_iam_instance_profile.ec2iam_profile.name}"

  tags = {
    Name = "pin ec2"
  }

  user_data = file("${path.root}/ec2/userdata.tpl")

  root_block_device {
    volume_size = 10
  }
}

# Crear y asociar ip
resource "aws_eip" "eip" {
  instance = aws_instance.node.id
}


# resource "aws_iam_instance_profile" "ec2iam_profile" {
#   name  = "ec2iam_profile"
#   role = ["${instance_role.name}"]
# }

# resource "aws_iam_policy" "policy" {
#   name        = "ec2-admin-pin2"
#   description = "Este es un rol para manejar ec2"
#   policy      =  file("${path.root}/ec2/ec2admin.json")
# }

# resource "aws_iam_role" "instance" {
#   name               = "instance_role"
#   path               = "/system/"
#   assume_role_policy = file("${path.root}/ec2/ec2admin.json")
# }