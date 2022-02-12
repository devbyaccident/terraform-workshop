# Getting Set up for Exercises and Experiments

In this first exercise we'll make sure that we're all set up with our AWS credentials and access to AWS, and then we'll
create a Cloud9 server/environment where we'll run further exercises.

## Log into the AWS Console and Create an Access Key for yourself

1. Log in to AWS using the link, username, and password provided to you
1. In the top bar, near the right, you'll see your username/alias @ introterraform. Clicking on that will display a dropdown
1. In the dropdown, click on "My Security Credentials"
1. This will take you to your security credentials screen/tab. Feel free to change your password if you like, you'll be using this account for the next 2 days.
1. Click "Create access key"
1. An access key and secret will be created for you, **copy the Access key ID and Secret access key (or download a CSV file), we'll use them in setting your environment up below**
1. Close out of the modal/pop-up

## Launch your Environment

1. In the top bar of the AWS Console, near the left, you'll see "AWS Services", click on it, and in the drop down search box, type "Cloud9" which will filter available services in the search list. Click on "Cloud9" which will take you to where we can create your environment.
1. **IMPORTANT**: Select **US East (N. Virginia)** in the upper right corner of your AWS console as the region
1. Click on "Create Environment"
1. Give your environment a unique name (your student alias is suggested) and, optionally, a description. Click "Next"
1. Keep the settings as their defaults on this screen, then click "Next"
1. Review your settings on the next screen, and then click "Create"
1. Wait for your environment to start. In this step, AWS is provisioning an EC2 instance on which your IDE environment will run. This gives us the distinct advantage of having a consistent and concontrolled environment for development regardless of client hardware and OS. It also allows us to connect to our instances and AWS's API without worrying about port availability in a corporate office. :-)
1. Once your IDE loads, you should see a Welcome document. Your instructor will give you a walkthrough of the visible panel. Feel free to take a moment to read through the welcome document.


## Configure your environment

1. Below the Welcome Document, you should see a terminal panel.
1. Feel free to resize the terminal panel to your liking.
1. This is a fully functioning bash terminal running inside an EC2 instance, but it is the base AWS Linux OS and doesn't have the things we need to execute this workshop, so lets install a few packages.

```bash
sudo yum -y install jq git unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws*
aws --version
```

## Install Terraform

Run these commands in your cloud9 IDE terminal window to install Terraform

Find complete instructions here:

`https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started#install-terraform`

```bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform
```

Then test to ensure it was installed properly.

```bash
terraform -v
```

If you get an error, inform your instructor.

## Pull the exercises repository

The next thing we need to do is pull this repository down so we can use it in future modules. Run the following to 
do this:

```bash
mkdir -p workshop
cd workshop
git clone https://github.com/devbyaccident/terraform-workshop .
```

## Set up your environment credentials to connect to AWS

Now we need to add the access and secret access keys to our AWS Profile. Enter `aws configure`, then put in the following values when prompted:

```bash
Access Key ID: [AWS Access Key]
Secret Access Key: [AWS Secret Access Key]
Region: us-east-1
Output: [Leave this blank]
```

There will be AWS credentials setup on Cloud9 already, but they don't have enough privileges to run the labs.

Once the new credentials have been added, you'll be asked if you want to Force Update. Say no to update Cloud9 with the new keys.

Now if you run `aws configure list-profiles` you should see the `default` profile.
Run the command below to add this AWS profile to your `~/.bash_profile`. Any AWS CLI commands after this will use the `default` profile.

```bash
echo 'AWS_PROFILE=default' >> ~/.bash_profile
source ~/.bash_profile
```

Having done that, we should be ready to move on!
