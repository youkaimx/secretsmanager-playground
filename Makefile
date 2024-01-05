BUCKET="youkaimx-tf"
REGION="us-east-2"
KEY=$(shell basename $$PWD)/terraform.tfstate

init:
	terraform init -backend-config="bucket=$(BUCKET)" -backend-config="key=$(KEY)" -backend-config="region=$(REGION)"
#	terraform init -backend-config=config.s3.tfbackend
fmt:
	terraform fmt
plan:
	terraform plan

validate:
	terraform validate

apply:
	terraform apply -auto-aprove

destroy:
	terraform apply -destroy -auto-aprove

precommit:
	pre-commit run -a

precommit-u:
	pre-commit autoupdate

precommit-i:
	pre-commit install
