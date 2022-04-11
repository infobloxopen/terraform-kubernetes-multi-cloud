locals {
  cloud_provider = get_env("TF_VAR_cloud_provider", "azure")
  kubeconfig = get_env("TF_VAR_kubeconfig", "")

  module_sources = jsondecode(get_env("TF_VAR_module_sources", file("${get_terragrunt_dir()}/module_sources.json")))
  source = local.module_sources[coalesce(local.cloud_provider, "azure")]
}

inputs = {  
  cloud_provider = local.cloud_provider
  kubeconfig = local.kubeconfig
}

terraform {
  after_hook "generate_provider_module_after_download" {
    commands = ["init"]
    execute  = ["${get_terragrunt_dir()}/generate_provider_module.sh", "${local.source}"]
  }

  before_hook "generate_provider_module_before_run" {
    commands = get_terraform_commands_that_need_vars()
    execute = ["${get_terragrunt_dir()}/generate_provider_module.sh", "${local.source}"]
  }
}




# this generates a provider.tf file in the local directory based on the selected cloud provider
generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite"
  contents = <<EOT
provider "kubernetes" {
  config_path = var.kubeconfig

  experiments {
    manifest_resource = true
  }
}

%{ if local.cloud_provider == "alicloud" ~}
provider "alicloud" {
  access_key = var.ali_access_key
  secret_key = var.ali_secret_key
  region     = var.ali_region
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

# module for ${local.cloud_provider}


# Kubeconfig files are expected to be output by the provider module

output "kubeconfig" {
  value = "module.provider.kubeconfig_path"
}

output "provider" {
  value = "${local.cloud_provider}"
}

output "provider_info" {
  value = jsonencode(module.provider.provider_info)
}

EOT
}

generate "terragrunt-init-required" {
  path = ".terragrunt-init-required"
  if_exists = "overwrite"
  contents = ""
}
