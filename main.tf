# aws_kms_key
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key
resource "aws_kms_key" "this" {
  description             = "A first Customer Managed CMK"
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}
# aws_kms_alias
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias
# Provides an alias for a KMS customer master key. AWS Console enforces 1-to-1 mapping
# between aliases & keys, but API (hence Terraform too) allows you to create as many
# aliases as the account limits allow you.

resource "aws_kms_alias" "this" {
  target_key_id = aws_kms_key.this.id
  name          = "alias/apps/${var.project_short_name}"
}

# Policies for keys
# https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-overview.html
# Example: https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-overview.html

resource "aws_kms_key_policy" "this" {
  key_id = aws_kms_key.this.id
  policy = data.aws_iam_policy_document.kms_policy.json
}
# aws_secretsmanager_secret
resource "aws_secretsmanager_secret" "this" {
  provider                = aws.secretsmanager
  kms_key_id              = aws_kms_key.this.id
  name_prefix             = "${var.project_short_name}/namespace/secret-"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "this" {
  provider      = aws.secretsmanager
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = "{\"username\":\"foobar\",\"password\":\"barbaz\"}"
}

data "aws_secretsmanager_random_password" "random_password" {
  password_length = 24
}

resource "aws_secretsmanager_secret" "random_password" {
  provider                = aws.secretsmanager
  kms_key_id              = aws_kms_key.this.id
  name_prefix             = "${var.project_short_name}/namespace/random-password-"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "random_password_version" {
  provider      = aws.secretsmanager
  secret_id     = aws_secretsmanager_secret.random_password.id
  secret_string = data.aws_secretsmanager_random_password.random_password.random_password
}

output "foobar" {
  value = data.aws_secretsmanager_version.random_password_version.value
}
