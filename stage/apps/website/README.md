# Stage - Website App

This project manages resources related to the _Website_ applications runtime concerns within a stage-environment.

The project manages the following:

- S3 Bucket for storing compiled static assets used within the application.
  Upon each application deployment this bucket is synced with the latest compiled assets (handled by the CI pipline).
- CloudFront distribution used to front both the static asset S3 bucket (with according PoP caching) and the API-gateway provisioned/managed by the application itself.
  This single distribution allows us to host both the application and static assets from the same domain (asset requests being found at the `/build` path prefix) which is best practise.
  As we want all traffic to be sent via the distribution we lock down the publicly accessible API-gateway using a pre-shared key, guarded at the application layer (front-controller).
  We also include a CloudFront function which is used to manage _www_ to _apex_ URL redirects, which is easier to manage than a dedicated ALB/S3 bucket alternative approach.
- Managed SSL certificates (via ACM) and assoicated Route 53 records for the given applications CloudFront distribution.
  An optional vanity Route53 hosted zone can be supplied, which is provisioned alongside the stage-environment hosted zone for customer-facing application access.
- DynamoDB table for application session state (with record TTLs for self-cleaning).
- SQS woker queue (and associated dead-letter queue) used by the application to handle asynchronous compute workloads.
- Lambda runtime permission policy which includes all permissions required by the runtime to use resources provisioned in this project.
- Runtime secrets and parameters shared with the application itself using SSM and Secrets Manager.
  Only knowledge shared with the application that is deemeed secret is stored within Secrets Manager.
  Secret values are pulled in at runtime (with explicit auditing in-place), as such, they incur a larger performance cost than SSM parameters which are baked into the Lambda runtime configuration.
- IAM user with required permissions to deploy the application itself.
  This is used within the application CI pipeline (GitHub workflows) to deploy the desired build within the stage-envioronemnt.

_Note_: Typically, knowledge sharing between Terraform and the appliication itself is unidirectional.
However, the CloudFront distribution does require knowledge of the desired application API-gateway resource.
This leads to a chicken and egg scenario, where-by which set of resources should your provisioned first.
It is advised to provision the resources found in this project first (with a dummy API-gateway parameter), and then upon successful deployment replace with the generated API-gateway.

## Resource seperation

The rule currently employed within this _service_ is any application runtime concern which does not change based on a CI pipeline deployment (i.e. Lambda function/API-gateway) should be managed within Terraform.
This is due to the size of the service, and being owned by a single individual.

An alternative way of seperating runtime resources between the application itself (Serverless Framework) and Terraform is based on stake-holder ownership.
This is best employed in a large, multidisciplinary team setting.
For example, the foundational infrastructure may be owned and managed by the Operations/SRE team, with the runtime/code required to run the application being owned by the Development team.
The Development team can depend on infrastructure setup by the Operations/SRE team via Secrets Manager secrets and SSM parameters.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.27.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.3.2 |
| <a name="requirement_template"></a> [template](#requirement\_template) | >= 2.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.2.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.27.0 |
| <a name="provider_aws.us_east_1"></a> [aws.us\_east\_1](#provider\_aws.us\_east\_1) | 4.27.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.3.2 |
| <a name="provider_template"></a> [template](#provider\_template) | 2.2.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cloudfront_cache_policy.website](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy) | resource |
| [aws_cloudfront_distribution.website](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_function.viewer_request](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_function) | resource |
| [aws_cloudfront_origin_access_identity.assets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_cloudfront_origin_request_policy.website](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_request_policy) | resource |
| [aws_dynamodb_table.sessions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_iam_access_key.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_policy.website](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.origin_response](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.origin_response](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_user.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy_attachment.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_lambda_function.origin_response](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_route53_record.app_apex](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.app_cert_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.app_www](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.vanity_apex](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.vanity_cert_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.vanity_www](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.assets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.assets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.assets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_secretsmanager_secret.admin_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.auto_generated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.mailer_dsn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.page_content](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.admin_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.auto_generated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.mailer_dsn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.page_content](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_sqs_queue.worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue.worker_dlq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_ssm_parameter.assets_bucket_name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.email_notifier_from](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.email_notifier_to](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.host](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.origin_domain_auth_key_header](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.sessions_table_name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.website_policy_arn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.worker_queue_arn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.worker_queue_url](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [random_password.auto_generated](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [archive_file.origin_response](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_route53_zone.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_route53_zone.vanity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [template_file.viewer_request](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [terraform_remote_state.network](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.security](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_TFC_WORKSPACE_NAME"></a> [TFC\_WORKSPACE\_NAME](#input\_TFC\_WORKSPACE\_NAME) | Provided by Terraform Cloud so as to determine the stage | `string` | n/a | yes |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | The password which is used to login to the admin system | `string` | n/a | yes |
| <a name="input_aws_access_key_id"></a> [aws\_access\_key\_id](#input\_aws\_access\_key\_id) | n/a | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | `"eu-west-1"` | no |
| <a name="input_aws_secret_access_key"></a> [aws\_secret\_access\_key](#input\_aws\_secret\_access\_key) | n/a | `string` | n/a | yes |
| <a name="input_email_notifier_from"></a> [email\_notifier\_from](#input\_email\_notifier\_from) | The address to send email notifications from | `string` | n/a | yes |
| <a name="input_email_notifier_to"></a> [email\_notifier\_to](#input\_email\_notifier\_to) | The addresses to send email notifications to | `list(string)` | n/a | yes |
| <a name="input_mailer_dsn"></a> [mailer\_dsn](#input\_mailer\_dsn) | The desired Symfony Mailer DSN used for sending email | `string` | n/a | yes |
| <a name="input_origin_domain_auth_key_header"></a> [origin\_domain\_auth\_key\_header](#input\_origin\_domain\_auth\_key\_header) | The authentication key header used to proxy requests to origin | `string` | `"X-CloudFront-Auth-Key"` | no |
| <a name="input_origin_domain_name"></a> [origin\_domain\_name](#input\_origin\_domain\_name) | The API-GW domain name which hosts the Website | `string` | n/a | yes |
| <a name="input_page_content"></a> [page\_content](#input\_page\_content) | The content displayed within the defined site sections | `string` | n/a | yes |
| <a name="input_vanity_dns_zone_id"></a> [vanity\_dns\_zone\_id](#input\_vanity\_dns\_zone\_id) | Optional, primary DNS zone to configure, used for customer-facing domains | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_deploy_user"></a> [deploy\_user](#output\_deploy\_user) | Credentials used by Serverless Framework to deploy the application |
<!-- END_TF_DOCS -->
