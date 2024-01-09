provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  region = "us-east-2"
  alias  = "secretsmanager"
  assume_role {
    role_arn     = aws_iam_role.secretsmanager_operator.arn
    external_id  = "verySecretExternalId"
    session_name = "SecretsManagerSession"
  }
}


terraform {
  backend "s3" {}
}
