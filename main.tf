resource "aws_key_pair" "terraKey" {
  key_name   = "terraform-demo-ali"  # Replace with your desired key name
  public_key = file("~/.ssh/id_rsa.pub")  # Replace with the path to your public key file
}

resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "sub1" {
  cidr_block = var.sub1_cidr
  vpc_id = aws_vpc.myvpc.id
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1a"
}

resource "aws_security_group" "sg" {
  name        = "sg"
  description = "sg"
  vpc_id      = aws_vpc.myvpc.id

  tags = {
    Name = "sg"
  }

  ingress {
    description = "HTTP"
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress{
    description = "SSH"
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
}

resource "aws_internet_gateway" "igw" {

    vpc_id = aws_vpc.myvpc.id

}

resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "RT"
  }
}
resource "aws_route_table_association" "rta1"{
    subnet_id = aws_subnet.sub1.id
    route_table_id = aws_route_table.RT.id
}

resource "aws_instance" "webserver1" {
  ami="ami-0dee22c13ea7a9a67"
  instance_type = "t2.micro"
  key_name = aws_key_pair.terraKey.key_name
  subnet_id = aws_subnet.sub1.id
  vpc_security_group_ids = [aws_security_group.sg.id]

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host = self.public_ip
  }

  #provisoners
  #file provisioner to copy a file from local to remote !
  provisioner "file" {
    source = "app.py"
    destination = "/home/ubuntu/app.py" #replace with the path on remote instance
  }

   provisioner "remote-exec" {
    inline = [
      "echo 'Hello from the remote instance'",
      "sudo apt update -y",  # Update package lists (for ubuntu)
      "cd /home/ubuntu",
      "sudo apt-get install -y python3-flask",  # Example package installation
      
     # "sudo pip3 install flask",
      "sudo python3 app.py &",
    ]
  }
}