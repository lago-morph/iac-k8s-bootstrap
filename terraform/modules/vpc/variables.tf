variable "instance_type" {
  description = "The instance type to use"
  type        = string
  default     = "t3.medium"
}

variable "numAZs" {
  description = "The number of AZs to use"
  type        = number
  default     = 3
}

variable "nodes" {
  description = "The number of nodes.  Must be >= numAZs."
  type        = number
  default     = 3
}

variable "region" {
  description = "AWS region to use"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Base string used to generate names for resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR for the VPC created"
  type        = string
  default     = "10.0.0.0/16"
}
