variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "regtech-eks"
}

variable "region" {
    type = string
    default = "us-east-2"
}