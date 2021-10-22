#!/bin/bash

values=$(terraform output -json)

let i=0
for username in $(echo $values | jq -r '.students.value[].name'); do
  for loop in 1; do
	echo "Instructions repo:     https://github.com/devbyaccident/terraform-workshop"
	echo "Console URL:           https://introterraform.signin.aws.amazon.com/console"
	echo "Username/Alias:        $username"
	password=$(echo $values | jq -r '.passwords.value[]['"$i"']' | base64 --decode | gpg -dq)
	echo "AWS Console Password:  $password"
	region=$(echo $values | jq -r '.students.value['"$i"'].region')
	echo "Exercise 11 Region:    $region"
	echo "Link to the slides:    http://bit.ly/terraform-day-1"
	echo "Instructor email:      chris@devbyaccident.com"
	#echo "Course Evaluation:     $(cat survey-link)"
	echo ""
	echo ""
	echo ""
	let i=i+1
  done > tf-user$i
done
