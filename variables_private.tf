# variables defined here are only used by the multi-cloud module during code generation in terragrunt.real.hcl

variable "module_sources" {
  description = "json map of git resources for the cloud providers"
  type = string
  default = ""
}

variable "cloud_provider" {
  description = "Specify the target cloud provider (aws / azure / gcp)"
  type        = string
  validation {
      condition     = contains(["aws", "azure", "gcp"], var.cloud_provider)
      error_message = "Valid values for var: cloud_provider are (aws, azure, gcp)."
  } 
}