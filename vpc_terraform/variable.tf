variable "cidr" {
 default = "10.0.0.0/16"
}

variable "subnet_cidr" {
 default ="10.0.0.0/24"
}

variable "subnet_cidr2" {
 default ="10.0.1.0/24"
}

variable "tags" {
    type = object({
        name = string
    })
    default = {
        name = "vpc-terraform"
    }
}

variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
  
}