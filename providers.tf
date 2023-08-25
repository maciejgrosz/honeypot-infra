# Provider configuration
provider "aws" {
  region  = var.aws_region
  profile = "sandbox"
}