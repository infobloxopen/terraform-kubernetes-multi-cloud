locals {
  cloud_provider = get_env("TF_VAR_cloud_provider", "microsoft")
  kubeconfig = get_env("TF_VAR_kubeconfig", "")
}

inputs = {  
  cloud_provider = local.cloud_provider
  kubeconfig = local.kubeconfig

  module_sources = {
    "aws": "https://github.com/pjferrell//terraform-aws-k8s",
    "azurerm": "https://github.com/pjferrell/terraform-azurerm-k8s",
    "google": "https://github.com/pjferrell/terraform-google-k8s",
    "alicloud": "https://github.com/pjferrell/terraform-alicloud-k8s",
  }
}

# this generates a provider.tf file in the local directory based on the selected cloud provider
generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite"
  contents = <<EOT
%{ if local.cloud_provider == "alicloud" ~}
provider "alicloud" {
  access_key = var.ali_access_key
  secret_key = var.ali_secret_key
  region     = var.ali_region
}
%{ endif ~}
%{ if local.cloud_provider == "aws" ~}
provider "aws" {
  region = var.region
  # credentials will read from ~/.aws
}
%{ endif ~}
%{ if local.cloud_provider == "google" ~}
provider "google" {
  credentials = file("account.json")
  project     = var.gcp_project
  region      = var.region
}
%{ endif ~}
%{ if local.cloud_provider == "microsoft" ~}
provider "azurerm" {
  client_id = var.az_client_id
  client_secret = var.az_client_secret
  tenant_id = var.az_tenant_id
  subscription_id = var.az_subscription_id
  features {}
}
%{ endif ~}
%{ if local.cloud_provider == "oracle" ~}
provider "oci" {
  tenancy_ocid     = var.oci_tenancy_ocid
  user_ocid        = var.oci_user_ocid
  fingerprint      = var.oci_fingerprint
  private_key_path = var.oci_private_key_path
  public_key_path  = var.oci_public_key_path
  region           = var.oci_region
}
%{ endif ~}
EOT
}

generate "main" {
  path = "main.tf"
  if_exists = "overwrite"
  contents = <<EOT

# Provider for ${local.cloud_provider}
module "${local.cloud_provider}" {
  count = 1
  enable_${local.cloud_provider} = true
  kubeconfig = var.kubeconfig
%{ if local.cloud_provider == "alicloud" ~}
  source = "git::https://git@github.com/pjferrell/terraform-alicloud-k8s.git?ref=master"
%{ endif ~}
%{ if local.cloud_provider == "aws" ~}
  source = "git::https://git@github.com/pjferrell/terraform-aws-k8s.git?ref=master"
%{ endif ~}
%{ if local.cloud_provider == "google" ~}
  source = "git::https://git@github.com/pjferrell/terraform-google-k8s.git?ref=master"
%{ endif ~}
%{ if local.cloud_provider == "microsoft" ~}
  source  = "git::https://git@github.com/pjferrell/terraform-azurerm-k8s.git?ref=master"
  az_client_id = var.az_client_id
  az_client_secret = var.az_client_secret
  az_tenant_id = var.az_tenant_id
  az_subscription_id = var.az_subscription_id
%{ endif ~}
}

# Kubeconfig files in main module directory
# (will be created in submodule directories, too)

resource "local_file" "kubeconfig-${local.cloud_provider}" {
  count = var.enable_${local.cloud_provider} ? 1 : 0
  content  = module.${local.cloud_provider} ? module.${local.cloud_provider}.kubeconfig_path_${local.cloud_provider} : ""
  filename = "${local.kubeconfig}"

  depends_on = [module.${local.cloud_provider}]
}
EOT
}

generate "terragrunt-init-required" {
  path = ".terragrunt-init-required"
  if_exists = "overwrite"
  contents = ""
}
