# Network

This provides the foundational stage-based networking infrastructure required to run the defined applications.

The project creates the following:

- VPC with public and private subnets (desired AZ's supplied by `var.availability_zones`)
- Single spot-based NAT instance provisioned in the defined availability zone (`var.nat_availability_zone`), used for outbound internet access within the private subnets.
- Stage-based Route53 hosted-zones for each application (i.e. `website.staging.*`), based on the domain supplied by the [shared-network](../../shared/network) project. This is used as a trade-off between reliablity (NAT Gateway handles multi-AZ and failover for you) and cost (a single spot-instance is very cheap).
- Optional VPC endpoints for key AWS services (SQS, Secrets manager and DynamoDB), for improved reliability/security.

_Note:_ The NAT-instance can be accessed by using [AWS Systems Manager Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html).
