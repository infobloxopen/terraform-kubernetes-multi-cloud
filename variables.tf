variable "cloud_provider" {
  description = "Specify the target cloud provider (aws / azure / gcp)"
  type        = string
  validation {
      condition     = contains(["aws", "azure", "gcp"], var.cloud_provider)
      error_message = "Valid values for var: cloud_provider are (aws, azure, gcp)."
  } 
}

variable "kubeconfig" {
  description = "Specify the location of the kubeconfig"
  type        = string
}

## Kubernetes worker nodes
variable "nodes" {
  description = "Worker nodes (e.g. `2`)"
  type        = number
  default     = 2
}

## Alibaba Cloud
variable "ali_access_key" {
  description = "Alibaba Cloud AccessKey ID"
  type        = string
  default     = ""
}

variable "ali_secret_key" {
  description = "Alibaba Cloud Access Key Secret"
  type        = string
  default     = ""
}


### Amazon
variable "aws_profile" {
  description = "AWS cli profile (e.g. `default`)"
  type        = string
  default     = "default"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-1"
}


## Digital Ocean
variable "do_token" {
  description = "Digital Ocean personal access (API) token"
  type        = string
  default     = ""
}


## Google Cloud
variable "gcp_project" {
  description = "GCP Project ID"
  type        = string
  default     = ""
}


## Microsoft Azure
variable "az_client_id" {
  description = "Azure Service Principal appId"
  type        = string
  default     = ""
}

variable "az_client_secret" {
  description = "Azure Service Principal password"
  type        = string
  default     = ""
}

variable "az_tenant_id" {
  description = "Azure Service Principal tenant"
  type        = string
  default     = ""
}

variable "az_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = ""
}


### Oracle Cloud Infrastructure
variable "oci_user_ocid" {
  description = "OCI User OCID"
  type        = string
  default     = ""
}

variable "oci_tenancy_ocid" {
  description = "OCI Tenancy OCID"
  type        = string
  default     = ""
}

variable "oci_fingerprint" {
  description = "OCI SSH public key fingerprint"
  type        = string
  default     = ""
}
