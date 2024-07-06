# Introduction
This simple IAC demo will use terrafrom script to create ec2 instance and RDS instance.
ec2 instance will host php web page that interact with RDS database.

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
```
terraform plan
```
```
terraform apply
```
## Remove cloud resource 
```
terraform destroy
```


## Reference
1. https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Tutorials.WebServerDB.CreateWebServer.html
2. https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/TUT_WebAppWithRDS.html

   
