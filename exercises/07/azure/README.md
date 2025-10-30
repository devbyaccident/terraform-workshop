# Exercise #7: Error Handling, Troubleshooting

We'll take some time to look at what the different types of errors we discussed look like. In each part of this 
exercise you'll get a feel for some common error scenarios and how to fix or address them.

### Process Errors

So, as mentioned, process errors are really about just something problematic in way that terraform is being run. 
So, what happens when you run `apply` before `init`? Let's run apply here before init:

```bash
terraform apply
```

You should see something like:

```
│ Error: Inconsistent dependency lock file
│ 
│ The following dependency selections recorded in the lock file are inconsistent with the current configuration:
│   - provider registry.terraform.io/hashicorp/azurerm: required by this configuration but no version is selected
│ 
│ To make the initial dependency selections that will initialize the dependency lock file, run:
│   terraform init
```

One of `init`'s jobs is to ensure that dependencies like providers, modules, etc. are pulled
in and available locally within your project directory. If we don't run `init` first, none of
our other terraform operations have all the requirements they need to do their job.

How about another process error example, the apply command has an argument that will tell it
to never prompt you for input variables: `-input=[true|false]`. By default, it's true, but we
could try running `apply` with it set to false.

```bash
terraform init
unset TF_VAR_student_alias && terraform apply -input=false
```

Which should give you something like:

```
Error: No value for required variable

  on variables.tf line 4:
   4: variable "student_alias" {

The root module input variable "student_alias" is not set, and has no default value. Use a -var or -var-file command line argument to provide a
value for this variable.
```

### Syntactical Errors

Let's modify the `main.tf` file here to include something invalid. At the end of the file, add this:

```hcl
resource "azurerm_storage_blob" "an_invalid_resource_definition" {
```

Clearly a syntax problem, so let's run

```
terraform plan
```

And you should see something like

```
│ Error: Unclosed configuration block
│ 
│   on main.tf line 22, in resource "azurerm_storage_blob" "an_invalid_resource_definition":
│   22: resource "azurerm_storage_blob" "an_invalid_resource_definition" {
│ 
│ There is no closing brace for this block before the end of the file. This may be caused by incorrect brace nesting elsewhere in this file.
```

The goal is to get used to what things look like depending on the type of error encountered. These syntax 
errors happen early in the processing of Terraform commands.

### Validation Errors

This one might not be as clear as the syntax problem above. Let's pass something invalid
to the AWS provider by setting a property that doesn't jive with the `azurerm_storage_blob`
resource as defined in the AWS provider. We'll modify the syntax issue above slightly, so change
your resource definition to be:

```hcl
resource "azurerm_storage_blob" "an_invalid_resource_definition" {
  name                   = "student.alias"
  storage_container_name = "data"
  type                   = "Block"
  source_content         = "This container is reserved for ${var.student_alias}"
}
```

Nothing seemingly wrong with the above when looking at it, unless you know that the `storage_account_name` property
is a required one on this type of resource. So, let's see what terraform tells us about this:

```bash
terraform validate
```

First, here we see the `terraform validate` command at work. We could just as easily do a `terraform plan`
and get a similar result. Two benefits of validate:

1. It allows validation of things without having to worry about everything we would in the normal process of plan or apply. For example, variables don't need to be set.
2. Related to the above, it's a good tool to consider for a continuous integration and/or delivery/deployment pipeline. Failing fast is an important part of any validation or testing tool.

If you were to have run `terraform plan` here, you would've still been prompted for the `student_alias` value
(assuming of course you haven't set it in otherwise).

Having run `terraform validate` you should see immediately something like the following:

```
│ Error: Missing required argument
│ 
│   on main.tf line 14, in resource "azurerm_storage_blob" "student_alias_blob":
│   14: resource "azurerm_storage_blob" "student_alias_blob" {
│ 
│ The argument "storage_account_name" is required, but no definition was found.
```

So, our provider is actually giving us this. The AWS provider defines what a `azurerm_storage_blob` should include,
and what is required. The `storage_account_name` property is required, so it's tell us we have a problem with this resource defintion.

### Provider Errors or Passthrough

And now to the most frustrating ones! These may be random, intermittent. They will be very specific to the provider and problems
that happen when actually trying to do the work of setting up or maintaining your resources. Let's take a look at a simple example.
Modify the invalid resource we've been working with here in `main.tf` to now be:

```hcl
resource "azurerm_storage_blob" "a_resource_that_will_fail" {
  name                   = "file"
  storage_account_name   = "notarealstorageaccount"
  storage_container_name = "this-wont-work"
  type                   = "Block"
  source_content         = "This will never exist"
}
```

Then run

```
terraform apply
```

And you should see something like:

```
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_storage_blob.a_resource_that_will_fail will be created
  + resource "azurerm_storage_blob" "a_resource_that_will_fail" {
      + access_tier            = (known after apply)
      + content_type           = "application/octet-stream"
      + id                     = (known after apply)
      + metadata               = (known after apply)
      + name                   = "file"
      + parallelism            = 8
      + size                   = 0
      + source_content         = "This will never exist"
      + storage_account_name   = "notarealstorageaccount"
      + storage_container_name = "this-wont-work"
      + type                   = "Block"
      + url                    = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_storage_blob.a_resource_that_will_fail: Creating...
╷
│ Error: locating Storage Account "notarealstorageaccount"
│ 
│   with azurerm_storage_blob.a_resource_that_will_fail,
│   on main.tf line 14, in resource "azurerm_storage_blob" "a_resource_that_will_fail":
│   14: resource "azurerm_storage_blob" "a_resource_that_will_fail" {
│ 
```

Where is this error actually coming from? In this case, it's the Azure Blob Storage API. It's trying to place a blob into a storage account that 
doesn't exist. Terraform is making the related API call to try and create the blob, but Azure can't do it because the bucket 
in which we're trying to put the blob either doesn't exist or we don't own it, so we get this error passed back to us.

One other thing worth noting–Did everything fail?

```
azurerm_storage_blob.a_resource_that_will_fail: Creating...
azurerm_storage_blob.student_alias_blob: Creating...
azurerm_storage_blob.student_alias_blob: Creation complete after 2s [id=https://....blob.core.windows.net/data/student.alias]
╷
│ Error: locating Storage Account "notarealstorageaccount"
│ 
│   with azurerm_storage_blob.a_resource_that_will_fail,
│   on main.tf line 22, in resource "azurerm_storage_blob" "a_resource_that_will_fail":
│   22: resource "azurerm_storage_blob" "a_resource_that_will_fail" {
```

Nope! Our first storage blob that was valid was created, only the second one failed. Terraform will complete 
what it can and fail on what it can't. Sometimes the solution to failures can sometimes just be running 
the same Terraform multiple times (e.g., if there's a network issue between where you're running Terraform and Azure).

### Finishing this exercise

First, remove the offending HCL now in `main.tf`

```
resource "azurerm_storage_blob" "a_resource_that_will_fail" {
  name                   = "file"
  storage_account_name   = "notarealstorageaccount"
  storage_container_name = "this-wont-work"
  type                   = "Block"
  source_content         = "This will never exist"
}
```

And then

```
terraform destroy
```

Once the resources have all been destroyed, run `rm -rf .terraform` and raise your hand.