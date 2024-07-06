# Introduction
This simple IAC demo will use terrafrom script to create ec2 instance and RDS instance.
Take note you will likely incur charges 

## Pre-Requisite
- AWS account

## Setup Terraform in AWS cloudshell

### Download Terraform into home folder

```
curl -o terraform.zip https://releases.hashicorp.com/terraform/1.9.1/terraform_1.9.1_darwin_arm64.zip
```
```
mkdir bin
mv terraform.zip ./bin/
unzip bin/terraform.zip
```

   
