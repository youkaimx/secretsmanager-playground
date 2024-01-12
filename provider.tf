# provider "aws" {
#   region = "us-east-2"
#   default_tags {
#     tags = local.default_tags
#   }
# }

variable "tfc_aws_dynamic_credentials" {
  description = "Object containing AWS dynamic credentials configuration"
  type = object({
    default = object({
      shared_config_file = string
    })
    aliases = map(object({
      shared_config_file = string
    }))
  })
}

provider "aws" {
  shared_config_files = [var.tfc_aws_dynamic_credentials.default.shared_config_file]
  region              = "us-east-2"
}

# provider "aws" {
#   alias = "ALIAS1"
#   shared_config_files = [var.tfc_aws_dynamic_credentials.aliases["ALIAS1"].shared_config_file]
# }
#
#
#provider "aws" {
#  region = "us-east-2"
#  alias  = "kms"
#  assume_role {
#    role_arn     = aws_iam_role.kmsadmin.arn
#    external_id  = "verySecretExternalId"
#    session_name = "KMSTestRoleSession"
#  }
#}
##
#provider "aws" {
#  region = "us-east-2"
#  alias  = "secretsmanager"
#  assume_role {
#    role_arn     = aws_iam_role.secretsmanager_operator.arn
#    external_id  = "verySecretExternalId"
#    session_name = "SecretsManagerSession"
#  }
#}



# terraform {
#   backend "s3" {}
# }

terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "rvaldez"

    workspaces {
      name = "secretsmanager-playground"
    }
  }
}
