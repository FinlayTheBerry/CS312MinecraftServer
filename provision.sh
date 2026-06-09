#!/bin/sh

cd "$(dirname "$(realpath "$0")")"

if ! which aws 1>/dev/null 2>&1; then
    echo "The aws cli could not be found. Ensure the aws binary is installed and in your path."
    exit 1
fi

if ! which terraform 1>/dev/null 2>&1; then
    echo "Terraform could not be found. Ensure the terraform binary is installed and in your path."
    exit 1
fi

if ! aws sts get-caller-identity 1>/dev/null 2>&1; then
    echo "You are not logged into the aws cli."
    echo 'To fix this run "aws configure" or write your credentials into "~/.aws/credentials".'
    exit 1
fi

terraform init 1>/dev/null
terraform apply
