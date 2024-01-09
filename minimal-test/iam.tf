data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy_document" "trust_this" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["${data.aws_caller_identity.current.account_id}"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values = [
        "verySecretExternalId"
      ]
    }
  }
}

data "aws_iam_policy_document" "secretsmanager_operator" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:UntagResource",
      "secretsmanager:DescribeSecret",
      "secretsmanager:PutSecretValue",
      "secretsmanager:CreateSecret",
      "secretsmanager:DeleteSecret",
      "secretsmanager:TagResource",
      "secretsmanager:UpdateSecret",
      "secretsmanager:GetSecretValue",
      #      "secretsmanager:GetRandomPassword",
    ]
    resources = ["arn:aws:secretsmanager:*:${data.aws_caller_identity.current.account_id}:secret:*"]
  }
}

resource "aws_iam_policy" "secretsmanager_operator_policy" {
  policy      = data.aws_iam_policy_document.secretsmanager_operator.json
  name_prefix = "SecretsManagerOperatorPolicy-minimal-test-"
}

resource "aws_iam_role" "secretsmanager_operator" {
  name_prefix        = "SecretsManagerOperatorRoleminimaltest-"
  assume_role_policy = data.aws_iam_policy_document.trust_this.json
}

resource "aws_iam_role_policy_attachment" "secretsmanager_operator_permissions" {
  policy_arn = aws_iam_policy.secretsmanager_operator_policy.arn
  role       = aws_iam_role.secretsmanager_operator.name
}
