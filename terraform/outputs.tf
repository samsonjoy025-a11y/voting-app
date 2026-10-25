output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.voting.name
}

output "cluster_endpoint" {
  description = "API endpoint for the EKS cluster"
  value       = aws_eks_cluster.voting.endpoint
}

output "aws_region" {
  description = "AWS region hosting the cluster"
  value       = var.aws_region
}

output "get_credentials_command" {
  description = "Command to configure kubectl access"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.voting.name}"
}
