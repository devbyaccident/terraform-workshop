#!/bin/bash

values=$(terraform output -json)
account_id=$(echo 'nope')

let i=0
jq -c '.student_credentials.value[]' <<<"$values" | while read -r user; do
  
	{
	  echo "Thank you for signing up for the Terraform class! For the next 2 days, we'll be covering Terraform which requires an Azure account. Please see the below information necessary for the class demos, and let me know if you have any questions or concerns."
	  echo
	  echo "Exercises repo:     https://github.com/devbyaccident/terraform-workshop"
	  username=$(jq -r '.username' <<<"$user")
	  password=$(jq -r '.password' <<<"$user")
	  alias=$(jq -r '.storage_account' <<<"$user")
	  echo "Username:        $username"
	  echo "Azure Portal Password:  $password"
	  echo "Student Alias:          $alias"
	  echo 
	  echo
	  echo "Regards,"
	  echo "- Chris Blackden"
	  echo "https://devbyaccident.com"
	  echo
	  echo "Sent with ProtonMail Secure Email."
	} > "tf-user$i"

	i=$((i+1))
done
