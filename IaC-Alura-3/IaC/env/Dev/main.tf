module "aws-dev" {
    source = "../../infrastructure"
    instance = "t2.micro"
    region_aws = "us-east-1"
    key = "IaC-DEV"
    security_group = "DEV"
    nomeGrupo = "DEV"
    min = 0
    max = 1
}

output "IP" {
    value = module.aws-dev.Ip_publico
}