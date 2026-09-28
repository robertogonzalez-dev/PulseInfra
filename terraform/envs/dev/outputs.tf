output "url" {
  description = "Public URL of the forecasting API (try /docs)"
  value       = module.service.url
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "cluster_name" {
  value = module.service.cluster_name
}

output "service_name" {
  value = module.service.service_name
}
