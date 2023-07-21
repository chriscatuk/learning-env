terraform {
  required_version = ">=1.5.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.9"
    }
  }
}


# Backend s3 is in backend.safe.tf
