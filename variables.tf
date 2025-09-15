variable "cidr_block" {
  type = string

}

variable "enable_dns_hostnames" {
  type    = bool
  default = true

}

variable "vpc_tags" {
  type    = map(any)
  default = {}

}
variable "project_name" {
  default = "expense"

}

variable "terraform" {
  default = true

}

variable "environment" {
  default = "dev"

}

variable "common_tags" {
  type = map(any)
  default = {

  }

}



variable "igw_tags" {
  default = {}

}


variable "public_cidr_blocks" {
  type = list(string)
  validation {
    condition     = length(var.public_cidr_blocks) == 2
    error_message = "for HA mention two cidrs"
  }
}

variable "public_subnet_tags" {
  default = {}

}

variable "private_cidr_blocks" {
  type = list(string)
  validation {
    condition     = length(var.private_cidr_blocks) == 2
    error_message = "for HA mention two cidrs"
  }

}

variable "private_subnet_tags" {
  default = {}

}

variable "database_cidr_blocks" {
  type = list(string)
  validation {
    condition     = length(var.database_cidr_blocks) == 2
    error_message = "for HA mention two cidrs"
  }

}

variable "database_subnet_tags" {
  default = {}

}
variable "eip_tags" {
  default = {}
}

variable "nat_tags" {
  default = {}

}

variable "peering_tags" {
  default = {}

}

variable "acceptor_vpc" {
  default = " "

}

variable "is_peering_required" {
  default = false

}
