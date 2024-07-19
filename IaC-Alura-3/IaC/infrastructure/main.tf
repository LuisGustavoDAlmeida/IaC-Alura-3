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
    user_data = var.prod ? filebase64("ansible.sh") : ""
}
# if(var.producao) {
#       filebase64("ansible.sh");
#   } else {
#       "";
#   }
#
#

resource "aws_key_pair" "chaveSSH" {
    key_name = var.key
    public_key = file("${var.key}.pub")
}

# Não é mais necessário por não estar trabalhando com instância AWS, então a saída do endereço ip não precisa mais
# output "Ip_publico" { 
#     value = aws_instance.app_server.public_ip
# }

resource "aws_autoscaling_group" "grupo" { ## Configurar grupo de escalamento automático
    availability_zones = ["${var.region_aws}a", "${var.region_aws}b"]
    name = var.nomeGrupo
    max_size = var.max
    min_size = var.min
    launch_template {
      id = aws_launch_template.maquina.id
      version = "$Latest"
    }
    target_group_arns = var.prod ? [aws_lb_target_group.target_load_balancer[0].arn] : []
}

resource "aws_default_subnet" "subnet_1" {
    availability_zone = "${var.region_aws}a"
}

resource "aws_default_subnet" "subnet_2" {
    availability_zone = "${var.region_aws}b"
}

resource "aws_lb" "load_balancer" {
    internal = false
    subnets = [aws_default_subnet.subnet_1.id, aws_default_subnet.subnet_2.id]
    count = var.prod ? 1 : 0
}

resource "aws_lb_target_group" "target_load_balancer" {
    name = "target_machine"
    port = "8000"
    protocol = "HTTP"
    vpc_id = default_vpc.id
    count = var.prod ? 1 : 0
}

resource "aws_default_vpc" "default_vpc" {}

resource "aws_lb_listener" "lb_entrance" {
    load_balancer_arn = aws_lb.load_balancer[0].arn
    port = "8000"
    protocol =  "HTTP"
    default_action {
        type = "forward" # Ele pega a requisição e passa pra frente
        target_group_arn = aws_lb_target_group.target_load_balancer[0].arn 
    }
    count = var.prod ? 1 : 0 
}

resource "aws_autoscaling_policy" "prod_scale" {
    name = "terraform_scale"
    autoscaling_group_name = var.nomeGrupo
    policy_type = "TargetTrackingScaling"
    target_tracking_configuration {
      predefined_metric_specification {
        predefined_metric_type = "ASGAverageCPUUtilization"
      }
      target_value = 50.0
    }
    count = var.prod ? 1 : 0
}