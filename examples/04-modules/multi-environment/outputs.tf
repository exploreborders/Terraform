# Network outputs for all environments
output "dev_vpc_id" {
  description = "Dev environment VPC ID"
  value       = module.networks["dev"].vpc_id
}

output "dev_public_subnet_ids" {
  description = "Dev environment public subnet IDs"
  value       = module.networks["dev"].public_subnet_ids
}

output "staging_vpc_id" {
  description = "Staging environment VPC ID"
  value       = module.networks["staging"].vpc_id
}

output "staging_public_subnet_ids" {
  description = "Staging environment public subnet IDs"
  value       = module.networks["staging"].public_subnet_ids
}

output "prod_vpc_id" {
  description = "Production environment VPC ID"
  value       = module.networks["prod"].vpc_id
}

output "prod_public_subnet_ids" {
  description = "Production environment public subnet IDs"
  value       = module.networks["prod"].public_subnet_ids
}

# Summary output
output "network_summary" {
  description = "Summary of all created networks"
  value = {
    for env, network in module.networks : env => {
      vpc_id              = network.vpc_id
      vpc_cidr           = network.vpc_cidr
      public_subnets     = length(network.public_subnet_ids)
      private_subnets    = length(network.private_subnet_ids)
      availability_zones = network.availability_zones
    }
  }
}