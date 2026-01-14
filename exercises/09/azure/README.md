# Exercise #9: Resource Counts and Conditional HCL

The idea of "looping" or repeated resource capabilities in Terraform is one of the most encountered gotchas. 
Declarative infrastructure tools and languages often require or encourage more explicit definition of things 
rather than supporting logic where other languages might have an "easier" way of doing things. Nonetheless, 
there's still a good deal you can accomplish via Terraform's `count` concept that mimicks the idea of loops 
and creating multiple copies or versions of a single thing. 

Modules, as we saw, are another key aspect of reusability in Terraform.

But let's take a look at `count` in action for the sake of reusability and list of common infrastructure
objects, and related logical support for the sake of dynamic resource management.

Run the following in this directory

```bash
terraform init
terraform plan
```

You should see something like the following

```
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_storage_blob.dynamic_file[0] will be created
  + resource "azurerm_storage_blob" "dynamic_file" {
      + access_tier            = (known after apply)
      + content_type           = "application/octet-stream"
      + id                     = (known after apply)
      + metadata               = (known after apply)
      + name                   = "dynamic-file-0"
      + parallelism            = 8
      + size                   = 0
      + source_content         = "dynamic-file at index 0"
      + storage_account_name   = "..."
      + storage_container_name = "data"
      + type                   = "Block"
      + url                    = (known after apply)
    }

  # azurerm_storage_blob.dynamic_file[1] will be created
  + resource "azurerm_storage_blob" "dynamic_file" {
      + access_tier            = (known after apply)
      + content_type           = "application/octet-stream"
      + id                     = (known after apply)
      + metadata               = (known after apply)
      + name                   = "dynamic-file-1"
      + parallelism            = 8
      + size                   = 0
      + source_content         = "dynamic-file at index 1"
      + storage_account_name   = "..."
      + storage_container_name = "data"
      + type                   = "Block"
      + url                    = (known after apply)
    }

  # azurerm_storage_blob.dynamic_file[2] will be created
  + resource "azurerm_storage_blob" "dynamic_file" {
      + access_tier            = (known after apply)
      + content_type           = "application/octet-stream"
      + id                     = (known after apply)
      + metadata               = (known after apply)
      + name                   = "dynamic-file-2"
      + parallelism            = 8
      + size                   = 0
      + source_content         = "dynamic-file at index 2"
      + storage_account_name   = "..."
      + storage_container_name = "data"
      + type                   = "Block"
      + url                    = (known after apply)
    }

  # azurerm_storage_blob.optional_file[0] will be created
  + resource "azurerm_storage_blob" "optional_file" {
      + access_tier            = (known after apply)
      + content_type           = "application/octet-stream"
      + id                     = (known after apply)
      + metadata               = (known after apply)
      + name                   = "optional-file"
      + parallelism            = 8
      + size                   = 0
      + source_content         = "optional-file"
      + storage_account_name   = "..."
      + storage_container_name = "data"
      + type                   = "Block"
      + url                    = (known after apply)
    }

Plan: 4 to add, 0 to change, 0 to destroy.

─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply"
now.
```

### The `count` parameter

Let's look at the `main.tf` file here to see what's going on. First, the `azurerm_storage_blob.dynamic_file` definition

```hcl
resource "azurerm_storage_blob" "dynamic_file" {
  count                  = var.object_count
  name                   = "dynamic-file-${count.index}"
  storage_account_name   = var.student_alias
  storage_container_name = "data"
  type                   = "Block"
  source_content         = "dynamic-file at index ${count.index}"
}
```

So, there's a variable controlling the number of `dynamic_file` objects that will actually be created, let's look at the
`variables.tf` file, and we see our `object_count` variable definition

```hcl
variable "object_count" {
  type        = number
  description = "number of dynamic objects/files to create"
  default     = 3
}
```

And it has a default value of *3*, so our `azurerm_storage_blob` resource uses the `count` property to dynamically define the number
of "copies" of this resource we'd like. This all adds up to our plan telling us that the following would be created:

```
azurerm_storage_blob.dynamic_file[0] will be created
azurerm_storage_blob.dynamic_file[1] will be created
azurerm_storage_blob.dynamic_file[2] will be created
```

### Conditional HCL Resources

The count parameter, now in combination with the `bool` type is particularly useful for conditionally including
things in your ultimately built infrastructure. Let's look at our `main.tf` again to see an example

```hcl
resource "azurerm_storage_blob" "optional_file" {
  count                  = var.include_optional_file ? 1 : 0
  name                   = "optional-file"
  storage_account_name   = var.student_alias
  storage_container_name = "data"
  type                   = "Block"
  source_content         = "optional-file"
}
```

So, our `count   = var.include_optional_file ? 1 : 0` syntax says: if the `include_optional_file` variable is set to true, we
want one instance of this object, otherwise we want 0. Could you think of another way to produce the same result? Hint: it's how
you had to do it before the `bool` data type came around.

We see in our plan output

```
  # azurerm_storage_blob.optional_file[0] will be created
  + resource "azurerm_storage_blob" "optional_file" {
      + access_tier            = (known after apply)
      + content_type           = "application/octet-stream"
      + id                     = (known after apply)
      + metadata               = (known after apply)
      + name                   = "optional-file"
      + parallelism            = 8
      + size                   = 0
      + source_content         = "optional-file"
      + storage_account_name   = ...
      + storage_container_name = "data"
      + type                   = "Block"
      + url                    = (known after apply)
    }
```

And in our variables file

```hcl
variable "include_optional_file" {
  type        = bool
  default     = true
}
```

So, indeed our optional file/object would be created/maintained since we're using the default `include_optional_file=true`. Try 
another plan, but with

```
terraform plan -var include_optional_file=false
```

Is it what you expected? If you have a little extra time, play around more with count and other ways that you might achieve 
conditional logic in HCL. Ask questions if you have them, or raise your hand if you're done.

Then, let's move on!
