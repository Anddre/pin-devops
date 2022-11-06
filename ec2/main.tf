
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

# Obtener el nombre de la politica
data "aws_iam_policy" "required-policy" {
  name = "AdministratorAccess"
}


# Rol para la politica
resource "aws_iam_role" "role" {
  name = "ec2-admin-role"
  path = "/"
  assume_role_policy = file("${path.root}/ec2/ec2admin.json")
}


# Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.role.name
}


# Attachear la policy al rol
resource "aws_iam_role_policy_attachment" "attach-ec2admin" {
  role       = aws_iam_role.role.name
  policy_arn = data.aws_iam_policy.required-policy.arn
}


# Crear una instancia ec2 con os ubuntu 20.04
resource "aws_instance" "node" {
  instance_type          = "t2.micro" # free instance
  ami                    = "ami-0066d036f9777ec38"
  key_name               = aws_key_pair.key_pair.id
  vpc_security_group_ids = [var.public_sg]
  subnet_id              = var.public_subnet

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.id
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
