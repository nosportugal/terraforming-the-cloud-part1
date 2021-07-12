#!/bin/bash

tfversion=1.0.1

wget "https://releases.hashicorp.com/terraform/$tfversion/terraform_${tfversion}_linux_amd64.zip"
unzip -o terraform_${tfversion}_linux_amd64.zip
mv -f terraform /usr/local/bin/terraform
rm terraform_${tfversion}_linux_amd64.zip

# check that terraform is on the selected version
terraform version