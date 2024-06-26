module "aws-dev" {
    source = "../../infrastructure"
    instance = "t2.micro"
    region_aws = "us-east-1"
    key = "IaC-DEV"
    security_group = "DEV"
    minimo = 0
    maximo = 1
    nomeGrupo = "DEV"
}

output "IP" {
    value = module.aws-dev.Ip_publico
}