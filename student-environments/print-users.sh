#!/bin/bash

values=$(terraform output -json)
account_id=$(aws sts get-caller-identity --output text | awk '{print $1}')

let i=0
for username in $(echo $values | jq -r '.students.value[].name'); do
  for loop in 1; do
	echo "Thank you for signing up for the Introduction to Terraform class! I'm excited to work with you all for the next 2 days. Please see the below information necessary for the class demos, and let me know if you have any questions or concerns."
	echo ""
	echo "Instructions repo:     https://github.com/devbyaccident/Introduction-to-Terraform"
	echo "Console URL:           https://$account_id.signin.aws.amazon.com/console"
	echo "Username/Alias:        $username"
	password=$(echo $values | jq -r '.passwords.value[]['"$i"']' | base64 --decode | gpg -dq)
	echo "AWS Console Password:  $password"
	region=$(echo $values | jq -r '.students.value['"$i"'].region')
	echo "Exercise 11 Region:    $region"
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
