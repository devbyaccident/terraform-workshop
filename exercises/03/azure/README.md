# Exercise #3: Plans and Applies

So now we are actually going to get into it and create some infrastructure! For this exercise, we are going to:

1. Initialize our project directory (i.e., this exercise directory)
1. Run a plan to understand why planning makes sense, and should always be a part of your terraform flow
1. Actually apply our infrastructure, in this case a single blob within our storage account
1. Destroy what we stood up

### Initialization

First, we need to run init since we're starting in a new exercise, or project directory:

```bash
terraform init
```

### Plan

Next step is to run a plan, which is a dry run that helps us understand what terraform intends to change when it 
runs an apply.  

Remember from the previous exercise that we'll need to make sure our `student_alias` value gets passed in appropriately.
Pick whichever method of doing so, and then run your plan:

```bash
terraform plan
```

Your output should look something like this:

```
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_storage_blob.student_alias_blob will be created
  + resource "azurerm_storage_blob" "student_alias_blob" {
      + access_tier            = (known after apply)
      + content_type           = "application/octet-stream"
      + id                     = (known after apply)
      + metadata               = (known after apply)
      + name                   = "student.alias"
      + parallelism            = 8
      + size                   = 0
      + source_content         = "This container is reserved for ..."
      + storage_account_name   = "..."
      + storage_container_name = "data"
      + type                   = "Block"
      + url                    = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

From the above output, we can see that terraform will create a single blob in our storage container.  An important line 
to note is the one beginning with "Plan:".  We see that 1 resource will be created, 0 will be changed, and 0 destroyed.  

Terraform is designed to detect when there is configuration drift in resources that it created and then intelligently 
determine how to correct the difference. This will be covered in more detail a little later.

### Apply

Let's go ahead and let Terraform create the storage blob. Maybe try a different method of passing in your `student_alias`
variable when running the apply:

```bash
terraform apply
```

Terraform will execute another plan, and then ask you if you would like to apply the changes. Type "yes" to approve, then
let it do its magic.  Your output should look like the following:

```
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_storage_blob.student_alias_blob will be created
  + resource "azurerm_storage_blob" "student_alias_blob" {
      + access_tier            = (known after apply)
      + content_type           = "application/octet-stream"
      + id                     = (known after apply)
      + metadata               = (known after apply)
      + name                   = "student.alias"
      + parallelism            = 8
      + size                   = 0
      + source_content         = "This container is reserved for ..."
      + storage_account_name   = "..."
      + storage_container_name = "data"
      + type                   = "Block"
      + url                    = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_storage_blob.student_alias_blob: Creating...
azurerm_storage_blob.student_alias_blob: Creation complete after 1s [id=https://....blob.core.windows.net/data/student.alias]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Now let's run a plan again.

```bash
terraform plan
```

You should notice a couple differences:

* Terraform informs you that it is Refreshing the State.
    * after the first apply, any subsequent plans and applies will check the infrastructure it created and updates the terraform state with any new information about the resource.
* Next, you'll notice that Terraform informed you that there are no changes to be made.  This is because the infrastructure was just created and there were no changes detected.

### Handling Changes

Now, let's try making a change to the blob and allow Terraform to correct it.  Let's change the content of our object.

Find `main.tf` and modify the blob to reflect the following:

```hcl
# declare a resource block so we can create something.
resource "azurerm_storage_blob" "student_alias_blob" {
  name                   = "student.alias"
  storage_account_name   = var.student_alias
  storage_container_name = "data"
  type                   = "Block"
  source_content         = "This container is reserved for ${var.student_alias} ****ONLY****"
}
```

Now run another apply:

```bash
terraform apply
```

The important output for the plan portion of the apply that you should note, something that looks like:

```
Terraform will perform the following actions:

  # azurerm_storage_blob.student_alias_blob must be replaced
-/+ resource "azurerm_storage_blob" "student_alias_blob" {
      ~ access_tier            = "Hot" -> (known after apply)
      ~ id                     = "https://....blob.core.windows.net/data/student.alias" -> (known after apply)
      ~ metadata               = {} -> (known after apply)
        name                   = "student.alias"
      ~ source_content         = "This container is reserved for ..." -> "This container is reserved for ...  ****ONLY****" # forces replacement
      ~ url                    = "https://....blob.core.windows.net/data/student.alias" -> (known after apply)
        # (6 unchanged attributes hidden)
    }

Plan: 1 to add, 0 to change, 1 to destroy.
```

A terraform plan informs you with a few symbols to tell you what will happen

* `+` means that terraform plans to add this resource
* `-` means that terraform plans to remove this resource
* `-/+` means that terraform plans to destroy then recreate the resource
* `+/-` is similar to the above, but in certain cases a new resource needs to be created before destroying the previous one, we'll cover how you instruct terraform to do this a bit later
* `~` means that terraform plans to modify this resource in place (doesn't require destroy then re-create)
* `<=` means that terraform will read the resource

So our above plan will destroy the blob, then re-create it with the new content.

Some resources or some changes can be done without destroying the resource, such as changing the password of an Entra ID User that is managed with terraform. Others, like storage blobs, need to be destroyed and recreated because the underlying API (In this case, the Azure API) does not allow for modifying them directly.

Terraform is generally made aware of these caveats and 
handles those changes gracefully, including updating dependent resources to link to the newly created resource. This
greatly simplifies complex or frequent changes to any size infrastructure and reduces the possibility of human error.

### Destroy

When infrastructure is retired, Terraform can destroy that infrastructure gracefully, ensuring that all resources
are removed and in the order that their dependencies require.  Let's destroy our s3 bucket object.

```bash
terraform destroy
```

You should get the following:

```
azurerm_storage_blob.student_alias_blob: Refreshing state... [id=https://....blob.core.windows.net/data/student.alias]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated
with the following symbols:
  - destroy

Terraform will perform the following actions:

  # azurerm_storage_blob.student_alias_blob will be destroyed
  - resource "azurerm_storage_blob" "student_alias_blob" {
      - access_tier            = "Hot" -> null
      - content_type           = "application/octet-stream" -> null
      - id                     = "https://....blob.core.windows.net/data/student.alias" -> null
      - metadata               = {} -> null
      - name                   = "student.alias" -> null
      - parallelism            = 8 -> null
      - size                   = 0 -> null
      - source_content         = "This container is reserved for ..." -> null
      - storage_account_name   = "..." -> null
      - storage_container_name = "data" -> null
      - type                   = "Block" -> null
      - url                    = "https://....blob.core.windows.net/data/student.alias" -> null
    }

Plan: 0 to add, 0 to change, 1 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

azurerm_storage_blob.student_alias_blob: Destroying... [id=https://....blob.core.windows.net/data/student.alias]
azurerm_storage_blob.student_alias_blob: Destruction complete after 1s

Destroy complete! Resources: 1 destroyed.
```

You'll notice that the destroy process if very similar to apply, just the other way around! And it also requires
confirmation, which is a good thing.

Run `rm -rf .terraform` to cleanup and raise your hand.