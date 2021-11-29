# Generate new private key 
resource "tls_private_key" "my_key" {
  algorithm = "RSA"
}

# Generate a key-pair with above key
resource "aws_key_pair" "deployer" {
  key_name   = "word-key"
  public_key = tls_private_key.my_key.public_key_openssh
}

# Saving Key Pair for ssh login for Client if needed
resource "null_resource" "save_key_pair"  {
	provisioner "local-exec" {
	    command = "echo  ${tls_private_key.my_key.private_key_pem} > mykey.pem"
  	}
}

# Creating Public Subnet for Wordpress
resource "aws_subnet" "public_subnet" {
  vpc_id     = "vpc-0dbc390c467e719e8"
  cidr_block = "10.6.5.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "murugt-public_subnet"
  }
}

# Creating Private Subnet for database
resource "aws_subnet" "private_subnet" {
  vpc_id     = "vpc-0dbc390c467e719e8"
  cidr_block = "10.6.224.0/22"
  
  tags = {
    Name = "murugt-private_subnet"
  }
}

# Creating Database Subnet group for RDS under our VPC
resource "aws_db_subnet_group" "db_subnet" {
  name       = "murugt-rds_db"
  subnet_ids = [aws_subnet.private_subnet.id, aws_subnet.public_subnet.id ]

  tags = {
    Name = "Murugt subnet group"
  }
}



# Creating a new security group for public subnet 
resource "aws_security_group" "SG_public_subnet" {
  name        = "MURUGT_WordPress_security_group"
  description = "Allow SSH and HTTP"
  vpc_id      =  "vpc-0dbc390c467e719e8"                   

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.40.0/22"]
  }

 ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
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

# Creating a new security group for private subnet 
resource "aws_security_group" "SG_private_subnet_" {
  name        = "MURUGT_MYSQL_security_group"
  description = "MYSQL"
  vpc_id      =  "vpc-0dbc390c467e719e8"              

  ingress {
    description = "MYSQL Port"
    from_port   = 3306
    to_port     = 3306
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


