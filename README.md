# Our Wedding Infrastructure

Because every Wedding RSVP website needs to be provisioned using Terraform (Cloud) within AWS.

## Overview

Foundational infrastructure for the Wedding _service_ is provisioned using [Terraform](https://www.terraform.io/) and [Terraform Cloud](https://www.terraform.io/cloud), and can be found within this repository.
Transient infrastructure such as Lambda functions/API-gateways (which change based on each deployment) are handled using the [Serverless Framework](https://www.serverless.com/); with the application itself being responsible for this.
Foundational resources created within Terraform can expose details to the transient application infrastructure by way of Secrets Manager and SSM parameters.

Below is a table detailing how each concern has been broken up into logical separated units.

| Context | Name                                       | Purpose                            | Example resources                        |
| ------- | ------------------------------------------ | ---------------------------------- | ---------------------------------------- |
| Shared  | [Network](./shared/network)                | Communication, spanning all stages | Route53 hosted zones for root domain     |
| Stage   | [Apps/`Application`](./stage/apps/website) | Fulfil runtime requirements        | CloudFront, SSM, SQS, SNS                |
| Stage   | [Data/`Application`](./stage/data/website) | Permanent storage                  | RDS, S3 (User uploads)                   |
| Stage   | Health                                     | Monitoring and alerting            | S3 (logs), CloudTrail, CloudWatch alarms |
| Stage   | [Network](./stage/network)                 | Communication, within stage        | VPC, VPC endpoints, DNS, NAT-instance    |
| Stage   | [Security](./stage/security)               | Security                           | KMS, WAF, GuardDuty                      |

### Project Contexts

Terraform projects which compose the the Wedding _service_ have been broken up into two seperate contexts - _Shared_ and _Stage_.

**Stage**

_Stage_ projects are for infrastructural concerns which relate to a given stage environment, for example `staging` and `prod`.
There is expected to be an instance of each given project per stage environment.
Resources within a project can be shared throughout the same environment, but not cross into different stage environments.

**Shared**

_Shared_ projects are for cross-cutting concerns which span all stages, and are shared throughout the _service_ as a whole.

Within Terraform Cloud we suffix the given project with the stage name to identify its' environment.
Resources within this _service_ have been designed in such a way that they can placed within the same AWS account, or multiple seperate AWS accounts.

### Stage Applications

The _service_ is composed of many _applications_ which are logically seperated within a given _stage_ based on runtime/storage requirements.
Currently there is only a single _application_ named Website, which manages the infrastructure for the RSVP website.
However, within the Wedding _service_ you could possibly see other applications such as a Wedding day photo upload service being added (unsure if I will have time to do this
😬).

## Tooling

There is a [Makefile](./Makefile) to provide tooling to assist continued development of _service_.
So as to ensure coding standards are met and any security issues caught before provisionment, the following tools are relied upon:

- [tflint](https://github.com/terraform-linters/tflint) - Fixes possible errors and enforces best-practises.
- [tfsec](https://github.com/aquasecurity/tfsec) - Static analysis tool to spot potential security issues.
- [tfdoc](https://github.com/terraform-docs/terraform-docs) - generates structured documentation for each Terraform project.

These tools are run (via `make can-release`) within a [GitHub workflow](./.github/workflows/test.yml) upon each push.
