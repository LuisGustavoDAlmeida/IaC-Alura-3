module "aws-Prod" {
    source = "../../infrastructure"
    instance = "t2.micro"
    region_aws = "us-east-1"
    key = "IaC-Prod"
    security_group = "Producao"
    nomeGrupo = "Prod"
    min = 1
    max = 10
}

# Não é mais necessário por não estar mais trabalhando com instância AWS
# output "IP" {
#    value = module.aws-Prod.Ip_publico
#}