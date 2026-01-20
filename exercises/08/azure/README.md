# Exercise #8: Understanding & Manipulating Data/Variables

This is one part of the course where we'll look at some very brand new stuff. Prior to terraform version 0.12,
which was released in May of this year, the only variable types available were:

* String
* List
* Map

As we just saw in our discussion, there are a number of others now, so let's look at them in action. As you go
along in this exercise, you're encouraged to change the HCL to experiment a bit with the different data types
and using them in action.

### Primitive Types

Terraform has restructured to include variable types in a category "primitive." These are quite similar to
what you'd find in other language primitives. Let's change into the `primitives` directory and run some terraform
to see primitives in action

```bash
cd primitives
terraform apply
```

We're not really creating any infrastructure in this exercise, rather just looking at the processing and output
of variables and data. You should see something like the following when running the above:

```
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

my_bool_negated = false
my_bool_value = my_bool is true
my_number_plus_two = 12
my_string_interpolated = my_string_value_interpolated
```

Now, take a look in the main.tf file and we'll look through each variable and each related output

```hcl
variable "my_string" {
  type    = string
  default = "my_string_value"
}
...
output "my_string_interpolated" {
  value = "${var.my_string}_interpolated"
}
```

The string type is probably the simplest of the primitives. It remains the default type if you don't explicitly set
a variable type. The above shows you the syntax for string interpolation. You could do this when defining resource
properties, not just in constructing outputs like the above. We've seen this when making our buckets or bucket object
names in the previous exercises.

```hcl
variable "my_number" {
  type    = number
  default = 10
}
...
output "my_number_plus_two" {
  value = "${var.my_number + 2}"
}
```

The `number` type is new in 0.12. The above shows how you can deal in this number variable directly by doing arithmetic.

```hcl
variable "my_bool" {
  type    = bool
  default = true
}
...
output "my_bool_negated" {
  value = "${!var.my_bool}"
}
output "my_bool_value" {
  value = "${var.my_bool == true ? "my_bool is true" : "my_bool is false"}"
}
```

The `bool` type is also new in 0.12. It gives you the power to perform boolean operations and checks in your HCL like we
see above in both the ternary and negation syntax to construct these output values.

### Complex Types

Complex types are made up of mostly new types and capabilities in v0.12. Let's take a look at them in action

```bash
cd complex
terraform apply
```

Running the above should give you something like

```
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

my_list_index_2 = 3
my_list_values = [
  "1",
  "2",
  "3",
]
my_map_values = {
  "ages" = [
    "12",
    "14",
    "10",
  ]
  "names" = [
    "John",
    "Susy",
    "Harold",
  ]
}
my_object_values = {
  "ages" = [
    12,
    14,
    10,
  ]
  "names" = [
    "John",
    "Susy",
    "Harold",
  ]
}
my_set_values = [
  1,
  2,
  3,
  4,
  5,
]
my_tuple_values = [
  "1",
  2,
  "3",
]
```

Let's look at each of the complex types individually and see what's actually going on in our `main.tf` file. Again, we're not
creating any infrastructure in this exercise, merely seeing variables getting set, then outputs being constructed from these
variable values. The way we're using these variables in outputs would apply to any other resource or use in your HCL.

```hcl
variable "my_list" {
  type      = list(string)
  default   = ["1", "2", "3"]
}
...
output "my_list_index_2" {
  value = "${var.my_list[2]}"
}

output "my_list_values" {
  value = "${var.my_list}"
}
```

The list type is not new in 0.12, and works similarly as it did before. In our example here, however, we're setting a [type
constraint](https://www.terraform.io/docs/configuration/types.html), so that our list can only contain string values. In
our two output examples, we see first an example of accessing a particular list item value, as well as using the entire list.

```hcl
variable "my_set" {
  type      = set(number)
  default   = [1, 2, 3, 4, 5]
}
...
output "my_set_values" {
  value = "${var.my_set}"
}
```

Sets are kinda like lists, but have their differences. We discussed them, but play around with the definition in the HCL here and
see if you can remember or identify what makes a set unique.

```hcl
variable "my_tuple" {
  type      = tuple([string, number, string])
  default   = ["1", 2, "3"]
}
...
output "my_tuple_values" {
  value = var.my_tuple
}
```

My guess is that you'll probably use tuples the least of any of the types. But we get to see it in action here nonetheless.
The key takeaway is that it's a list with mixed, strict type constraints.

```hcl
variable "my_map" {
  type      = map
  default   = {names: ["John", "Susy", "Harold"], ages: [12, 14, 10]}
}
...
output "my_map_values" {
  value = var.my_map 
}
```

Maps also allow a type constraint
for the related value(s). A map is just a collection of key/values.

```hcl
# How is this different than the map above?
variable "my_object" {
  type      = object({names: list(string), ages: list(number)})
  default   = {names: ["John", "Susy", "Harold"], ages: [12, 14, 10]}
}
...
output "my_object_values" {
  value = var.my_object
}
```

And finally the object type. Which is similar to map. But, can you identify the differences? Also, add some other outputs
of your own to access specific values in the object, change the object structure to see how far you can go with setting up
an object.

### Terraform Data and Reference

We've covered HCL data and variable concepts pretty completely at this point, but we want to finish off by looking closely
at one other thing: Terraform data sources and referencing these data sources.

Remember earlier when we queried the state of another terraform project? That was a Terraform data source. We want to look at how
providers allow you the ability to query particular sources to get things you need at runtime with the same mechanism. 
Two very common examples in the AWS provider:

1. Querying the current Azure subscription the provider is using.
1. Querying availability zone mappings in your current Azure region. This is useful for things like ensuring that you have a resource in every AZ for your region

So, let's look at some of this in action

```bash
cd ../other-data
terraform init
terraform apply
```

And you should get something like the following as the output

```
data.azurerm_location.this: Reading...
data.azurerm_location.this: Read complete after 1s [id=/subscriptions/84db9a41-af69-4475-b90d-63d83f0d71dc/locations/eastus2]

Changes to Outputs:
  + current_location = "eastus2"
  + zones = [
      + {
          + logical_zone  = "1"
          + physical_zone = "eastus2-az2"
        },
      + {
          + logical_zone  = "2"
          + physical_zone = "eastus2-az3"
        },
      + {
          + logical_zone  = "3"
          + physical_zone = "eastus2-az1"
        },
    ]

You can apply this plan to save these new output values to the Terraform state, without changing any real infrastructure.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes


Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

current_location = "eastus2"
zones = tolist([
  {
    "logical_zone" = "1"
    "physical_zone" = "eastus2-az2"
  },
  {
    "logical_zone" = "2"
    "physical_zone" = "eastus2-az3"
  },
  {
    "logical_zone" = "3"
    "physical_zone" = "eastus2-az1"
  },
])
```

There is one data source are being called here to provide two different pieces of information:

1. The current Azure location
1. The mapping of Physical Zones to Logical Zones (You can read more about why these are different [here](https://learn.microsoft.com/en-us/azure/reliability/availability-zones-overview?tabs=azure-powershell#physical-and-logical-availability-zones))

First, a look at the `main.tf` relevant resource that actually did the lookup for us. You can see the required parameters to use each data source in the Azure Provider documentation. 

```hcl
provider "azurerm" {
  features {}
}

data "azurerm_location" "this" {
  location = "East US 2"
}
```

After the data source resource is declared, we can then access it's attributes that have been populated by actually making the
query to Azure

```
output "zones" {
  value = data.azurerm_location.this.zone_mappings
}

output "current_location" {
  value = data.azurerm_location.this.location
}
```

### Finishing off this exercise

We're gonna do a little bit of experimenting as a way to finish off this exercise. This will give you an opportunity to play
a bit with things that look interesting to you in the HCL syntax, variable, and data usage areas:

1. Conditionals like ternary syntax, other expressions: https://www.terraform.io/language/expressions/conditionals
1. Interpolation, figuring what you can and can't do here
1. Built-in functions: https://www.terraform.io/docs/configuration/functions.html

Maybe try some of the above out with `terraform console`?

Once you're ready to move on, raise your hand.