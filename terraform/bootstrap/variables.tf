variable "region" {
  type    = string
  default = "us-east-1"
}

variable "github_repo" {
  description = "owner/name of the repo whose workflows may deploy"
  type        = string
  default     = "robertogonzalez-dev/PulseInfra"
}

variable "monthly_budget_usd" {
  type    = string
  default = "30"
}

variable "alert_email" {
  description = "Where budget alerts are sent"
  type        = string
}
