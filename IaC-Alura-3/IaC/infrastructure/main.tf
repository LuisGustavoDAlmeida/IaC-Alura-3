terraform {
required_providers {
    aws = {
    source  = "hashicorp/aws" // Provedor
    version = "~> 4.16"
    }
}
required_version = ">= 1.2.0"
}
provider "aws" {
    region = var.region_aws
}
resource "aws_launch_template" "maquina" {  
    image_id = "ami-04b70fa74e45c3917"  
    instance_type = var.instance
    key_name = var.key
    # user_data = <<-EOF
    #     #!/bin/bash
    #     cd /home/ubuntu
    #     echo "<h1> Ola, automacao feita com Terraform </h1> <br> <img src=\"./eu.jpg\" alt=\"\">" > index.html
    #     nohup busybox httpd -f -p 8080 &
    #                 EOF
    tags = {
        Name = "Terraform Ansible Python - Infra Elastica"
    }
    security_group_names = [var.security_group]
}

resource "aws_key_pair" "chaveSSH" {
    key_name = var.key
    public_key = file("${var.key}.pub")
}

output "Ip_publico" {
    value = aws_instance.app_server.public_ip
}

resource "aws_autoscaling_group" "grupo" {
    name = var.nomeGrupo
    max_size = var.maximo
    min_size = var.minimo
}