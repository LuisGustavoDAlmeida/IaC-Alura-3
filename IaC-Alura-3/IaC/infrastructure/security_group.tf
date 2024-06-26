resource "aws_security_group" "acesso_geral" {
    name = var.security_group
    # Portas
    ingress{
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
        from_port = 0
        to_port = 0
        protocol = "-1"
    } # Entrada
    egress{
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
        from_port = 0
        to_port = 0
        protocol = "-1"
    } # Saída
    tags = {
        name = "acesso_geral"
    }
}