resource "aws_iam_role" "kmsadmin" {
  name               = "KMSAdminRole"
  assume_role_policy = data.aws_iam_policy_document.trust_this.json

}

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

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


# IAM policy document
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "kms_policy" {
  # Hability to delegate for for the account
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::014834224223:root"]
    }
    actions = [
      "kms:*",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid    = "Key Administrators"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_role.kmsadmin.arn}"]
    }
    actions = [
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "Allow use of the key"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_role.kmsadmin.arn}", "${aws_iam_role.secretsmanager_operator.arn}"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]

    # Only use for requests done via secretsmanager
    # Reference https://docs.aws.amazon.com/kms/latest/developerguide/conditions-kms.html#conditions-kms-via-service
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["secretsmanager.${data.aws_region.current.name}.amazonaws.com"]
    }
    # Only use for secrets with a name prefix like ${var.project_short_name}
    # Reference https://docs.aws.amazon.com/kms/latest/developerguide/conditions-kms.html#conditions-kms-encryption-context
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:SecretARN"
      values   = ["arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${var.project_short_name}/*"]

    }
  }

  statement {
    sid    = "Allow attachment of persistent resources"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.kmsadmin.arn]
    }
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"


    ]
    resources = ["*"]
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}


data "aws_iam_policy_document" "secretsmanager_operator" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:CreateSecret",
      "secretsmanager:ListSecrets",
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:DescribeSecret",
      "secretsmanager:DeleteSecret",
      "secretsmanager:PutSecretValue",
      "secretsmanager:GetSecretValue",
    ]
    resources = ["arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${var.project_short_name}/*"]
  }
}

resource "aws_iam_policy" "secretsmanager_operator_policy" {
  policy = data.aws_iam_policy_document.secretsmanager_operator.json
  name   = "SecretsManagerOperatorPolicy"
}

resource "aws_iam_role" "secretsmanager_operator" {
  name               = "SecretsManagerOperatorRole"
  assume_role_policy = data.aws_iam_policy_document.trust_this.json
}

resource "aws_iam_role_policy_attachment" "secretsmanager_operator_permissions" {
  policy_arn = aws_iam_policy.secretsmanager_operator_policy.arn
  role       = aws_iam_role.secretsmanager_operator.name
}
