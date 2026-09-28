variable "name" {
  type = string
}

variable "keep_images" {
  type    = number
  default = 5
}

variable "force_delete" {
  description = "Allow `terraform destroy` to remove the repo even if it still has images"
  type        = bool
  default     = true
}
