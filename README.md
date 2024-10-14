# terraform-aws-provisioners

This Project

so the Developer comes to you saying that we have a application app.py you need to deploy it on infrastructure and check if it is working or not.
for that we will be creating a Terraform script to create the infrastructure and then deploy the app.py on that uch that application can check the changes are visible or not .


Provisioner 

In Terraform, provisioners are used to execute scripts or commands on a resource after it has been created or updated. They allow you to perform tasks that are necessary to configure the resource once it’s up and running. Provisioners can be especially useful for tasks such as installing software, copying files, or configuring services.

Key Types of Provisioners

1. local-exec:
Executes a command on the machine where Terraform is run, rather than on the remote resource itself.
Useful for running scripts or commands that don't need to be executed directly on the created resource.

resource "aws_instance" "example" {
  ami           = "ami-123456"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "echo Instance created with ID: ${self.id}"
  }
}


2. remote-exec:
Executes a command on the resource that Terraform just created.
Often used for tasks like installing packages or configuring services directly on a VM.

resource "aws_instance" "example" {
  ami           = "ami-123456"
  instance_type = "t2.micro"

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }
}

3. file:

Copies files from the machine where Terraform is executed to the resource being created.
This can be useful for transferring configuration files or scripts that the resource will need.

resource "aws_instance" "example" {
  ami           = "ami-123456"
  instance_type = "t2.micro"

  provisioner "file" {
    source      = "local_script.sh"
    destination = "/tmp/remote_script.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }
}



