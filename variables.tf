variable "prefix" {
  type    = string
  default = "kafkaclust"
}

variable "location" {
  type    = string
  default = "northeurope"
}

variable "address_space" {  
  default = ["10.0.0.0/16"] 
}




