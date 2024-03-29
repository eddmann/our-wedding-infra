# Stage - Website Data

This project manages resources related to the _Website_ applications data concerns within a stage-environment.
Currently, it is only responsible for the Serverless Aurora (PostgreSQL) database used within the runtime for persistent application state.

The long-term persistent data requirements are split from the application runtime as the two have different rates of change.
To expand upon this; resources found in the application runtime project can be re-created from scratch with minimal long-term impact (their data concerns are transisant in nature).
However, resources found in this project can not be easily recreated from strach, as in doing so we would lose state that is non-recoverable and vital to the overall applications health.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.35.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.3.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.35.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.4.3 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_db_subnet_group.website](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_rds_cluster.website](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster) | resource |
| [aws_rds_cluster_parameter_group.website](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_parameter_group) | resource |
| [aws_secretsmanager_secret.website_db_url](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.website_db_url](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [random_password.website_db_root_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [terraform_remote_state.network](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.security](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_TFC_WORKSPACE_NAME"></a> [TFC\_WORKSPACE\_NAME](#input\_TFC\_WORKSPACE\_NAME) | Provided by Terraform Cloud so as to determine the stage | `string` | n/a | yes |
| <a name="input_aws_access_key_id"></a> [aws\_access\_key\_id](#input\_aws\_access\_key\_id) | n/a | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | `"eu-west-1"` | no |
| <a name="input_aws_secret_access_key"></a> [aws\_secret\_access\_key](#input\_aws\_secret\_access\_key) | n/a | `string` | n/a | yes |
<!-- END_TF_DOCS -->
