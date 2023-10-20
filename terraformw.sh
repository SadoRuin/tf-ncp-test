#!/bin/bash 

echo "--------------------- Installing tfswitch locally for running terraform"

# Download terraform-switcher install file 
curl -O  https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh

# 실행 가능하도록 설정 변경
chmod 755 install.sh

# tfswitch 를 설치한다. 
./install.sh -b $(pwd)/.bin

# 설치 PATH를 환경변수에 저징한다. 
CUSTOMBIN=$(pwd)/.bin

# 환경 변수 PATH에 실행 파일을 설정한다. 
export PATH=$CUSTOMBIN:$PATH

# Copy Terraform Cloud credentials file
cat ./credentials.tfrc.json > /var/jenkins_home/.terraform.d/credentials.tfrc.json

$CUSTOMBIN/tfswitch -b $CUSTOMBIN/terraform

echo "--------------------- Running terraform init"
terraform init -no-color

echo "--------------------- Running terraform validate"
terraform validate -no-color

echo "--------------------- Running terraform plan"
terraform plan -out=tfplan -detailed-exitcode -no-color
export EXITCODE=$?

if [ $EXITCODE -eq 0 ]; then
  echo "ExitCode $EXITCODE: No changes in plan, exiting"
  exit 0
elif [ $EXITCODE -eq 2 ]; then
  echo "ExitCode $EXITCODE: Plan contains changes, proceeding"
  echo "--------------------- Running terraform apply"
  terraform apply tfplan -no-color
else
  echo "ExitCode $EXITCODE: Error running terraform plan, exiting"
  exit 1
fi