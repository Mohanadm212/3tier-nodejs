# Outputs
output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "rds_endpoint" {
  value = aws_db_instance.mydb.endpoint
}

output "jenkins_instance_public_ip" {
  value = aws_instance.jenkins_ec2.public_ip
}

output "sonarqube_instance_public_ip" {
  value = aws_instance.sonarqube_ec2.public_ip
}

output "monitoring_instance_public_ip" {
  value = aws_instance.monitoring_ec2.public_ip
}