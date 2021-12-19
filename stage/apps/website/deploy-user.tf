resource "aws_iam_user" "deploy" {
  name = format("our-wedding-website-%s-deploy", local.stage)
  path = format("/ourwedding/%s/", local.stage)

  tags = merge(local.tags, {
    Application = "Website"
  })
}

resource "aws_iam_access_key" "deploy" {
  user = aws_iam_user.deploy.name
}

resource "aws_iam_user_policy_attachment" "deploy" {
  user       = aws_iam_user.deploy.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
