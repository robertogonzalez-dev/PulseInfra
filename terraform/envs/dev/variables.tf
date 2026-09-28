variable "region" {
  type    = string
  default = "us-east-1"
}

variable "image_tag" {
  description = "Image tag to deploy; CI passes the PulseForecast commit SHA"
  type        = string
}

variable "use_spot" {
  type    = bool
  default = true
}
