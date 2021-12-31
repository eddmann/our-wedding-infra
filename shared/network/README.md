# Shared - Network

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.70.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.70.0 |

## Resources

| Name | Type |
|------|------|
| [aws_route53_record.stage_ns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.root](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route53_zone.stage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_access_key_id"></a> [aws\_access\_key\_id](#input\_aws\_access\_key\_id) | n/a | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | `"eu-west-1"` | no |
| <a name="input_aws_secret_access_key"></a> [aws\_secret\_access\_key](#input\_aws\_secret\_access\_key) | n/a | `string` | n/a | yes |
| <a name="input_root_domain_name"></a> [root\_domain\_name](#input\_root\_domain\_name) | The root domain name which hosts the service | `string` | n/a | yes |
| <a name="input_stages"></a> [stages](#input\_stages) | The stages that are present for this service | `list(string)` | <pre>[<br>  "staging",<br>  "prod"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_stage_zone_ids"></a> [dns\_stage\_zone\_ids](#output\_dns\_stage\_zone\_ids) | Route53 zone IDs for each defined stage, delegating provision responsibility to each stage network project |
| <a name="output_root_domain_name_servers"></a> [root\_domain\_name\_servers](#output\_root\_domain\_name\_servers) | NS records which can be supplied to a third-party domain registrar |
<!-- END_TF_DOCS -->