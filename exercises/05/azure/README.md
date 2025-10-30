# Exercise #5: Interacting with Providers

Providers are plugins that Terraform uses to understand various external APIs and cloud providers. Thus far in this
workshop, we've used the Azure provider, which uses the Azure Resource Manager (RM) API to create and check resources in Azure. In this exercise, we're going to modify the Azure provider we've been
using to use a specific subscription ID.

### Add the second provider

Add this variable block to the "variables.tf" file:

```hcl
provider "azurerm" {
  features {}
  skip_provider_registration = true
}
```

Then, add this provider block with the new region to `main.tf` just under the existing provider block exactly as-is. Note the `alias` argument–this is necessary when you have duplicate providers:

(Note: This is not going to work)
```hcl
provider "azurerm" {
  alias           = "alternate"
  subscription_id = "01234567-89ab-cdef-ghij-klmnopqrstuv"
  features {}
}
```

You can now specify the alternate provider when creating Azure resources:

```hcl
  provider = azurerm.alternate
```

Now, let's try to create a storage blob with the new provider. Find the **azurerm_storage_blob** resource and add the new provider alias. It should look like this:

```hcl
resource "azurerm_storage_blob" "student_alias_blob" {
  provider               = azurerm.alternate
  name                   = "student.alias"
  storage_account_name   = var.student_alias
  storage_container_name = "data"
  type                   = "Block"
  source_content         = "This container is reserved for ${var.student_alias}"
}
```
Run `terraform init`, then try to create that resource using the new provider you should get an error that looks like this:

```
> terraform apply                      

╷
│ Error: unable to build authorizer for Resource Manager API: could not configure AzureCli Authorizer: the provided subscription ID "01234567-89ab-cdef-ghij-klmnopqrstuv" is not known by Azure CLI
│ 
│   with provider["registry.terraform.io/hashicorp/azurerm"].alternate,
│   on main.tf line 14, in provider "azurerm":
│   14: provider "azurerm" {
│ 
╵
```
This is because the credentials you're using in the lab don't have permissions to that subscription ID, so Terraform is unable to authenticate to the Azure RM API.

In practice, this can be used to specify a different subscription for terraform to create or lookup resources in or specify different credentials to use like a Managed Service Identity.

Remove the **provider** parameter from the **azurerm_storage_blob** resource and try to create the blob again.

```bash
terraform init
terraform apply
```
The blob will be created with your provisioned credentials, which have the correct permissions.

We'll be looking more at using providers in other exercises as we move along.

### Finishing this exercise

Let's run the following to finish:

```
terraform destroy
```

Once the resources have all been destroyed, run `rm -rf .terraform` and raise your hand.