.PHONY: all deps

ENV_VAR_FILE := "./terraform/$(ENVIRONMENT)/terraform.tfvars"
BACKEND_CONF := "./terraform/$(ENVIRONMENT)/backend.conf"

# Default target
all: plan

# Install pipenv and the required dependencies for the backend (prod/dev)
install-deps:
	@echo "[INFO] Installing pipenv and dependencies in the backend"
	@cd backend && python -m pip install --no-input pipenv && python -m pipenv install

# Install the development dependencies for the backend
install-dev-deps:
	@echo "[INFO] Installing pipenv and development dependencies in the backend"
	@cd backend && python -m pip install --no-input pipenv && python -m pipenv install --dev

build-lambda-layer:
	@cd backend && pipenv requirements > requirements.txt && \
	mkdir -p python && \
	pip install -r requirements.txt -t python/ && \
	zip -q -r ../terraform/lambda_layer.zip python && \
	rm -rf python requirements.txt

terraform-init:
	@echo "[INFO] Initialiasing terraform with config $(BACKEND_CONF), environment file $(ENV_VAR_FILE)"
	@cd terraform/aws-infra && terraform init -reconfigure -backend-config=../$(ENVIRONMENT)/backend.conf -no-color
	
terraform-plan:
	@cd terraform/aws-infra && terraform plan -no-color -var-file=terraform.tfvars -var-file=$(ENV_VAR_FILE) -out=plan.out

terraform-apply:
	@cd terraform/aws-infra && terraform apply -no-color -auto-approve plan.out

terraform-destroy:
	@echo "[INFO] Destroying the environment using config $(BACKEND_CONF)"
	@cd terraform/aws-infra && terraform destroy -no-color -auto-approve -var-file=terraform.tfvars -var-file=$(ENV_VAR_FILE)

terraform-validate:
	@echo "[INFO] Validating terraform code."
	@cd terraform/aws-infra && terraform validate -no-color -var-file=$(ENV_VAR_FILE)