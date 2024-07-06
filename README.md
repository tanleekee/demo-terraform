# Introduction
This simple IAC demo will use terrafrom script to create ec2 instance and RDS instance.
Take note you will likely incur charges 

## Pre-Requisite
- AWS account

## Setup Terraform in AWS cloudshell

### Download Terraform and extract into Home folder

```
curl -o terraform.zip https://releases.hashicorp.com/terraform/1.9.1/terraform_1.9.1_darwin_arm64.zip
```
```
unzip terraform.zip -d bin/
```
### Verify terraform
```
terraform --version
```

## Running terraform to create cloud resources 
After terraform binary is installed, the next step is to download terraform script 
   
