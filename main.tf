# aws_kms_key
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key
resource "aws_kms_key" "key" {
  description             = "A first Customer Managed CMK"
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

# aws_kms_alias
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias
resource "aws_kms_alias" "alias" {
  target_key_id = aws_kms_key.key.id
  name          = "alias/apps/${var.project_short_name}"
}

# Policies for keys
# https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-overview.html
# Example: https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-overview.html

#resource "aws_kms_key_policy" "key_policy" {
#  key_id = aws_kms_key.key.id
#  policy = data.aws_iam_policy_document.kms_policy.json
#}
# aws_secretsmanager_secret
resource "aws_secretsmanager_secret" "secret" {
  #  provider                = aws.secretsmanager
  kms_key_id              = aws_kms_key.key.id
  name_prefix             = "${var.project_short_name}/my-app/provided-secret"
  recovery_window_in_days = 7
}

data "aws_secretsmanager_random_password" "random_password" {
  password_length = 24
}

resource "aws_secretsmanager_secret_version" "random_password_version" {
  #  provider      = aws.secretsmanager
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = data.aws_secretsmanager_random_password.random_password.random_password
}
