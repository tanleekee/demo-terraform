# Introduction
This simple IAC demo will use terrafrom script to create ec2 instance and RDS instance.
ec2 instance will host php web page that interact with RDS database.

## Pre-Requisite
- AWS account
- Computer with any modern browser with internet access

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
Create a demo folder
```
mkdir ~/demo
```
Download main.tf into demo folder
```
cd demo
curl -o main.tf https://aaaa
```
Initialise terraform
```
terraform init
```
Preview cloud resources creation
```
terraform plan
```
Create cloud resources. Terraform will prompt for confirmation. Enter yes to proceed, or no to cancel.
```
terraform apply
```
## Clean up cloud resources
```
terraform destroy
```

## ec2 creation
` this is code for ec2 creation`

## RDS creation
` this is code for RDS creation`

## Security Group creation
` this is code for SG creation`

## User Data

` this is code for user data`
> :bulb: **Tip:** Remember to appreciate the little things in life.


## Reference

1. https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Tutorials.WebServerDB.CreateWebServer.html

   
