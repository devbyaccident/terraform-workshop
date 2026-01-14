#!/bin/bash
# Use Azure CLI and Terraform together. This example logs in with Azure CLI and runs terraform.
if ! command -v az >/dev/null 2>&1; then
  echo "az CLI not found. Install Azure CLI first: https://learn.microsoft.com/cli/azure/install-azure-cli"
  exit 1
fi

# az login --only-show-errors
export TF_VAR_pgp_key=$(gpg --export "Chris Blackden" | base64)
terraform init
terraform "$@"
