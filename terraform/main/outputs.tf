output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.vpc.eks_cluster_name
}

output "region" {
  description = "The region we are using"
  value       = module.vpc.region
}
