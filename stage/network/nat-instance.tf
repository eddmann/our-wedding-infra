locals {
  nat_public_subnet_id = element(aws_subnet.public.*.id, index(var.availability_zones, var.nat_availability_zone))
  nat_name             = format("our-wedding-%s", local.stage)
  nat_name_prefix      = format("our-wedding-%s-nat-", local.stage)
}

#
# Network interface
#
resource "aws_security_group" "nat_instance" {
  name_prefix = local.nat_name_prefix
  vpc_id      = aws_vpc.main.id
  description = "Security group for ${local.nat_name} NAT instance"

  tags = local.tags
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.nat_instance.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
}

resource "aws_security_group_rule" "ingress_any" {
  security_group_id = aws_security_group.nat_instance.id
  type              = "ingress"
  cidr_blocks       = aws_subnet.private.*.cidr_block
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
}

resource "aws_network_interface" "nat_instance" {
  security_groups   = [aws_security_group.nat_instance.id]
  subnet_id         = local.nat_public_subnet_id
  source_dest_check = false
  description       = "ENI for ${local.nat_name} NAT instance"

  tags = local.tags
}

resource "aws_eip" "nat_instance" {
  vpc               = true
  network_interface = aws_network_interface.nat_instance.id

  tags = local.tags
}

resource "aws_route" "nat_instance" {
  count                  = length(var.availability_zones)
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.nat_instance.id
}

#
# Launch template
#
data "aws_ami" "latest_al2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }
}

resource "aws_iam_instance_profile" "nat_instance" {
  name_prefix = local.nat_name_prefix
  role        = aws_iam_role.nat_instance.name

  tags = local.tags
}

resource "aws_iam_role" "nat_instance" {
  name_prefix        = local.nat_name_prefix
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "nat_instance_ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.nat_instance.name
}

resource "aws_iam_role_policy" "nat_instance_eni" {
  role        = aws_iam_role.nat_instance.name
  name_prefix = local.nat_name_prefix
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AttachNetworkInterface"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_launch_template" "nat_instance" {
  name_prefix = local.nat_name_prefix
  image_id    = data.aws_ami.latest_al2.id

  iam_instance_profile {
    arn = aws_iam_instance_profile.nat_instance.arn
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.nat_instance.id]
    delete_on_termination       = true
  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.tags
  }

  user_data = base64encode(join("\n", [
    "#cloud-config",
    yamlencode({
      write_files : concat([
        {
          path : "/opt/nat/runonce.sh",
          content : templatefile(
            "${path.module}/resources/nat/runonce.sh",
            { eni_id = aws_network_interface.nat_instance.id }
          ),
          permissions : "0755",
        },
        {
          path : "/opt/nat/snat.sh",
          content : file("${path.module}/resources/nat/snat.sh"),
          permissions : "0755",
        },
        {
          path : "/etc/systemd/system/snat.service",
          content : file("${path.module}/resources/nat/snat.service"),
        },
      ]),
      runcmd : ["/opt/nat/runonce.sh"],
    })
  ]))

  description = "Launch template for ${local.nat_name} NAT instance"
  tags        = local.tags
}

#
# ASG
#
resource "aws_autoscaling_group" "nat_instance" {
  name_prefix         = local.nat_name_prefix
  desired_capacity    = 1
  min_size            = 1
  max_size            = 1
  vpc_zone_identifier = [local.nat_public_subnet_id]

  mixed_instances_policy {
    instances_distribution {
      spot_allocation_strategy = "lowest-price"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.nat_instance.id
        version            = aws_launch_template.nat_instance.latest_version
      }

      dynamic "override" {
        for_each = var.nat_spot_instance_types

        content {
          instance_type = override.value
        }
      }
    }
  }

  dynamic "tag" {
    for_each = local.tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
