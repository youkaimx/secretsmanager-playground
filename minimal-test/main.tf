## aws_secretsmanager_secret
resource "aws_secretsmanager_secret" "manual_password" {
  provider = aws.secretsmanager
  #  kms_key_id              = aws_kms_key.this.id
  name_prefix             = "${var.project_short_name}/my-app/provided-secret-"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "manual_password" {
  provider      = aws.secretsmanager
  secret_id     = aws_secretsmanager_secret.manual_password.id
  secret_string = "{\"username\":\"foobar\",\"password\":\"barbaz\"}"
}
#
data "aws_secretsmanager_random_password" "random_password" {
  password_length = 24
}
#
resource "aws_secretsmanager_secret" "random_password" {
  provider = aws.secretsmanager
  #  kms_key_id              = aws_kms_key.this.id
  name_prefix             = "${var.project_short_name}/my-app2/randompassword-"
  recovery_window_in_days = 7
}
resource "aws_secretsmanager_secret_version" "random_password_version" {
  provider      = aws.secretsmanager
  secret_id     = aws_secretsmanager_secret.random_password.id
  secret_string = data.aws_secretsmanager_random_password.random_password.random_password
}
