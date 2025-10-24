variable "vpc_cidr" {
  type        = string
  description = "CIDR block da VPC"
}

variable "vpc_name" {
  type        = string
  description = "Nome da VPC"
}

variable "public_subnets" {
  type        = list(string)
  description = "Lista de CIDRs das subnets públicas"
}

variable "private_subnets" {
  type        = list(string)
  description = "Lista de CIDRs das subnets privadas"
}

variable "azs" {
  type        = list(string)
  description = "Lista das zonas de disponibilidade"
}
