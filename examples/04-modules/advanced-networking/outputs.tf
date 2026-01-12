# Hub network outputs
output "hub_vpc_id" {
  description = "Hub VPC ID"
  value       = module.hub_network.vpc_id
}

output "hub_public_subnet_ids" {
  description = "Hub public subnet IDs"
  value       = module.hub_network.public_subnet_ids
}

output "transit_gateway_id" {
  description = "Transit Gateway ID"
  value       = aws_ec2_transit_gateway.main.id
}

# Spoke network outputs
output "spoke_networks" {
  description = "All spoke network information"
  value = {
    for name, network in module.spoke_networks : name => {
      vpc_id           = network.vpc_id
      vpc_cidr        = network.vpc_cidr
      public_subnets  = length(network.public_subnet_ids)
      private_subnets = length(network.private_subnet_ids)
      nat_gateway     = network.nat_gateway_id != null
    }
  }
}

# Transit Gateway attachments
output "transit_gateway_attachments" {
  description = "All Transit Gateway VPC attachments"
  value = {
    for name, attachment in aws_ec2_transit_gateway_vpc_attachment.spokes : name => {
      id              = attachment.id
      vpc_id          = attachment.vpc_id
      transit_gateway = attachment.transit_gateway_id
    }
  }
}

# Security group
output "cross_vpc_security_group_id" {
  description = "Security group for cross-VPC communication"
  value       = aws_security_group.cross_vpc.id
}

# Network topology summary
output "network_topology" {
  description = "Complete network topology summary"
  value = {
    hub = {
      vpc_id       = module.hub_network.vpc_id
      vpc_cidr    = module.hub_network.vpc_cidr
      subnets     = length(module.hub_network.public_subnet_ids) + length(module.hub_network.private_subnet_ids)
    }
    spokes = {
      for name, network in module.spoke_networks : name => {
        vpc_id    = network.vpc_id
        vpc_cidr = network.vpc_cidr
        subnets  = length(network.public_subnet_ids) + length(network.private_subnet_ids)
      }
    }
    connectivity = {
      transit_gateway_id = aws_ec2_transit_gateway.main.id
      attachments       = length(aws_ec2_transit_gateway_vpc_attachment.spokes) + 1  # +1 for hub
      cross_vpc_sg      = aws_security_group.cross_vpc.id
    }
  }
}