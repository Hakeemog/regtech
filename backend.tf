# # # backend.tf
terraform {
  backend "s3" {
    bucket         = "eks-cluster-regtech-project"
    key            = "state/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "regtech_tf"
  }
}