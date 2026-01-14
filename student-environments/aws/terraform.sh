#!/bin/bash

export TF_VAR_pgp_key=$(gpg --export "Chris Blackden" | base64)
terraform init
terraform $@
