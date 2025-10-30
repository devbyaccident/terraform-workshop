````markdown
# Getting Set up for Exercises and Experiments (Azure)

In this first exercise we'll make sure that we're all set up with an Azure account, the Azure CLI, and an Azure Cloud Shell environment where we'll run further exercises.

## Launch your Environment

1. Open the Azure Portal at https://portal.azure.com and sign in with your Azure account. 
1. Make sure to keep the password and setup a second-factor with the Microsoft Authenticator App to login to this account over the next few days.
1. Click the Cloud Shell icon (looks like >_) in the top-right of the portal to open Azure Cloud Shell.
1. If prompted, choose Bash as your shell and create the Cloud Shell storage account by selecting *Mount Storage Account*, then *Select existing storage account*. 
1. Select the training subscription, the resource group and storage account that contain your student ID, and create a new file share with the name **cloudshell**.
1. Wait for your Cloud Shell environment to initialize — it runs in a container backed by a storage account so you'll have a consistent shell environment for the exercises.

## Configure your environment

1. Below the Cloud Shell, you'll see a Bash terminal. Resize it if you like.
1. Cloud Shell generally includes the Azure CLI and Terraform already installed. To check versions run:

```bash
az --version
terraform -v
```

2. If you're running locally (not in Cloud Shell) and need to install tools, follow these steps.

Install Azure CLI (Linux):

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az --version
```

Install Terraform (Linux):

Follow HashiCorp's instructions; an example for Debian/Ubuntu:

```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform
terraform -v
```

If installation fails, notify your instructor.

## Login with Azure CLI (optional when using Cloud Shell)

If you're on your workstation, authenticate with the Azure CLI:

```bash
az login
# If you use multiple subscriptions, set the one you want to work in:
az account set --subscription "<subscription-id-or-name>"
```

## Pull the exercises repository

Clone the repository so the exercises are available in your Cloud Shell environment (or local machine):

```bash
mkdir -p workshop
cd workshop
git clone https://github.com/devbyaccident/terraform-workshop .
```

After that you should be ready to move on to the lab exercises.

````
