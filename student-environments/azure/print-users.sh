#!/bin/bash

values=$(terraform output -json)
account_id=$(echo 'nope')

let i=0
for username in $(echo $values | jq -r '.student_credentials
.value[].name'); do
  for loop in 1; do
	echo "Thank you for signing up for the Terraform class! For the next 2 days, we'll be covering Terraform which requires an AWS account. Please see the below information necessary for the class demos, and let me know if you have any questions or concerns."
	echo ""
	echo "Instructions repo:     https://github.com/devbyaccident/Introduction-to-Terraform"
	username=$(echo $values | jq -r '.student_credentials.value[].username' )
	echo "Username:        $username"
	password=$(echo $values | jq -r '.student_credentials.value[].password' )
	echo "Azure Portal Password:  $password"
	alias=$(echo $values | jq -r '.student_credentials.value[].storage_account' )
	echo "Student Alias:          $alias"
	echo "Instructor email:      chris@devbyaccident.com"
	#echo "Course Evaluation:     $(cat survey-link)"
	echo ""
	echo "Regards,"
	echo "- Chris Blackden"
	echo "https://devbyaccident.com "
	echo ""
	echo "Sent with ProtonMail Secure Email."
	echo ""

	let i=i+1
  done > tf-user$i
done
