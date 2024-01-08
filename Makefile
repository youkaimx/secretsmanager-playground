BUCKET="youkaimx-tf"
REGION="us-east-2"
KEY=$(shell basename $$PWD)/terraform.tfstate

init:
	terraform init -backend-config="bucket=$(BUCKET)" -backend-config="key=$(KEY)" -backend-config="region=$(REGION)"
#	terraform init -backend-config=config.s3.tfbackend
f:
	terraform fmt
p:
	terraform plan

v:
	terraform validate

a:
	terraform apply -auto-approve

d:
	terraform apply -destroy -auto-approve

precommit:
	pre-commit run -a

precommit-u:
	pre-commit autoupdate

precommit-i:
	pre-commit install
