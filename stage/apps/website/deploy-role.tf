resource "random_string" "deploy_external_id" {
  length  = 64
  special = false
}

resource "aws_iam_role" "deploy" {
  name_prefix = format("our-wedding-website-%s-", local.stage)

  assume_role_policy = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          },
          "Action": "sts:AssumeRole",
          "Condition": {
            "StringEquals": {
              "sts:ExternalId": "${random_string.deploy_external_id.result}"
            }
          }
        }
      ]
    }
  POLICY

  tags = merge(local.tags, {
    Application = "Website"
  })
}

resource "aws_iam_role_policy_attachment" "deploy" {
  role       = aws_iam_role.deploy.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
