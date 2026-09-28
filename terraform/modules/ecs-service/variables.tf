variable "name" {
  description = "Service name; used as a prefix for every resource"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,28}$", var.name))
    error_message = "Use 3-29 lowercase letters, digits or hyphens (ALB name limits)."
  }
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "image" {
  description = "Full image URI including tag"
  type        = string
}

variable "container_port" {
  type    = number
  default = 8000
}

variable "health_check_path" {
  type    = string
  default = "/health"
}

variable "cpu" {
  type    = number
  default = 512
}

variable "memory" {
  type    = number
  default = 1024
}

variable "min_count" {
  type    = number
  default = 1
}

variable "max_count" {
  type    = number
  default = 3
}

variable "use_spot" {
  description = "Run on Fargate Spot (~70% cheaper; tasks can be interrupted)"
  type        = bool
  default     = true
}

variable "container_insights" {
  type    = bool
  default = false
}

variable "environment" {
  description = "Plain-text environment variables for the container"
  type        = map(string)
  default     = {}
}
