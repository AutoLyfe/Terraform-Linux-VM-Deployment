variable "Prefix" {
  type        = string
  description = "The name of the resource group"
  default     = "Demo"
}

variable "location" {
  type        = string
  description = "The location of resources"
  default     = "South Africa North"
}


variable "tags" {
  type        = map(string)
  description = "resource tags"
  default = {
    Owner       = "Moses Morare"
    Environemnt = "Development"
  }
}


variable "vnet_address_space" {
  type        = list(any)
  description = "the address space of the VNet"
  default     = ["10.0.0.0/16"]
}


variable "subnets" {
  type = map(any)
  default = {
    subnet_1 = {
      name             = "subnet_1"
      address_prefixes = ["10.0.1.0/24"]
    }
    subnet_2 = {
      name             = "subnet_2"
      address_prefixes = ["10.0.2.0/24"]
    }
  }
}